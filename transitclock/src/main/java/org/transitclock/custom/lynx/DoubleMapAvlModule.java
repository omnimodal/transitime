/*
 * This file is part of transitclock.org
 * 
 * transitclock.org is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License (GPL) as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * transitclock.org is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Transitime.org .  If not, see <http://www.gnu.org/licenses/>.
 */
package org.transitclock.custom.lynx;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.HttpURLConnection;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.HashMap;
import java.util.zip.GZIPInputStream;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.transitclock.applications.Core;
import org.transitclock.avl.PollUrlAvlModule;
import org.transitclock.config.IntegerConfigValue;
import org.transitclock.config.StringConfigValue;
import org.transitclock.configData.AvlConfig;
import org.transitclock.db.structs.AvlReport;
import org.transitclock.db.structs.AvlReport.AssignmentType;
import org.transitclock.db.structs.Route;
import org.transitclock.db.structs.Stop;
import org.transitclock.db.structs.TripPattern;
import org.transitclock.modules.Module;
import org.transitclock.utils.IntervalTimer;
import org.transitclock.utils.Time;

/**
 * AVL module for reading AVL data, routes and stops information from DoubleMap feeds.
 * 
 * DoubleMap provides three API endpoints that can be used in conjunction to create AvlReports: `buses`, `routes` and `stops`.
 * The `stops` endpoint provides info on all the stops configured in the system, and is processed once at startup.
 * The `routes` endpoint provides info on currently active routes, and is processed periodically.
 * Both of these endpoints are used to create lookup tables between the internal DoubleMap IDS and the GTFS IDs.
 * The `buses` endpoint is the main AVL feed that is processed frequently.
 * 
 * Note that this module requires the Core to reference loaded GTFS data for matching, 
 * which is somewhat unusual for an AVL module in TheTransitClock.  
 * 
 * @author Sean Óg Crudden
 * @author Nathan Selikoff
 *
 */
public class DoubleMapAvlModule extends PollUrlAvlModule {

	private static StringConfigValue busesUrl = new StringConfigValue(
			"transitclock.avl.doubleMapBusesUrl", "http://golynx.doublemap.com/map/v2/buses",
			"The URL of the DoubleMap /buses endpoint (AVL feed)");

	private static StringConfigValue routesUrl = new StringConfigValue("transitclock.avl.doubleMapRoutesUrl",
			"http://golynx.doublemap.com/map/v2/routes", "The URL of the DoubleMap /routes endpoint (active routes feed)");

	private static StringConfigValue stopsUrl = new StringConfigValue("transitclock.avl.doubleMapStopsUrl",
			"http://golynx.doublemap.com/map/v2/stops", "The URL of the DoubleMap /stops endpoint (stop information feed)");

	/**
	 * How frequently the DoubleMap routes feed should be polled for new data.
	 * Should be at least 5 minutes (300 seconds) per API documentation
	 * @return 
	 */
	public static int getSecondsBetweenRoutesPolling() {
		return secondsBetweenRoutesPolling.getValue();
	}
	private static IntegerConfigValue secondsBetweenRoutesPolling =
			new IntegerConfigValue("transitclock.avl.doubleMapRoutesPollingRateSecs", 300,
					"How frequently the DoubleMap routes feed should be polled for new data. Should be at least 5 minutes (300 seconds) per API documentation.");

	IntervalTimer routesFeedPollingTimer = new IntervalTimer();
	
	// If debugging feed and want to not actually process
	// AVL reports to generate predictions and such then
	// set shouldProcessAvl to false;
	private static boolean shouldProcessAvl = true;
	
	// For matching DoubleMap internal route ID to GTFS route_id
	HashMap<Integer, String> routeLookup = new HashMap<Integer, String>();

	// For matching DoubleMap internal stop ID to GTFS stop_id
	HashMap<Integer, String> stopLookup = new HashMap<Integer, String>();

	private static final Logger logger = LoggerFactory.getLogger(DoubleMapAvlModule.class);

	/********************** Member Functions **************************/

	/**
	 * Constructor
	 * 
	 * @param agencyId
	 */
	public DoubleMapAvlModule(String agencyId) throws IllegalArgumentException, JSONException, MalformedURLException, IOException {
		super(agencyId);

		// Check that rate limits are not exceeded per DoubleMap API documentation
		if (getSecondsBetweenRoutesPolling() < 300) {
			throw new IllegalArgumentException("Polling rate too frequent; transitclock.avl.doubleMapRoutesPollingRateSecs must be 5 minutes (300 seconds) or greater");
		}
		if (AvlConfig.getSecondsBetweenAvlFeedPolling() < 10) {
			throw new IllegalArgumentException("Polling rate too frequent; transitclock.avl.feedPollingRateSecs must be 10 seconds or greater");
		}
		
		// Read in and process the stop and routes info so we can map to GTFS IDs.
		readDoubleMapStopData();
		readDoubleMapRouteData();
	}

	/**
	 * @return URL to use for polling AVL feed
	 */
	@Override
	protected String getUrl() {
		return busesUrl.getValue();
	}

	/**
	 * Called when AVL data is read from URL. Processes the JSON data and calls
	 * processAvlReport() for each AVL report. Also gets and processes routes data periodically.
	 * @param in
	 * @return Collection of AVL reports
	 */
	@Override
	protected Collection<AvlReport> processData(InputStream in) throws JSONException, IOException, MalformedURLException {
		// Process routes data if enough time has passed
		if (routesFeedPollingTimer.elapsedMsec() >= getSecondsBetweenRoutesPolling() * Time.MS_PER_SEC) {
			readDoubleMapRouteData();
			routesFeedPollingTimer.resetTimer();
		}
		
		Collection<AvlReport> avlReportsReadIn = new ArrayList<AvlReport>();

		// Get the JSON string containing the AVL data
		String jsonStr = getJsonString(in);

		JSONArray vehicles = new JSONArray(jsonStr);
		logger.debug("Processing {} vehicles from DoubleMap buses feed", vehicles.length());
		
		for (int i = 0; i < vehicles.length(); i++) {
			JSONObject vehicle = vehicles.getJSONObject(i);
			AvlReport avlReport = createAvlReportFromDoubleMapBus(vehicle);
			if (shouldProcessAvl) {
				avlReportsReadIn.add(avlReport);
			}
		}

		// Return all the AVL reports read in
		return avlReportsReadIn;			
	}
	
	/**
	 * Create an appropriate input stream for the given URL. Supports compression.
	 * @param fullUrl
	 * @return input stream
	 */
	protected InputStream getInputStream(String fullUrl) throws IOException, MalformedURLException {
		InputStream in = null;
		
		// Create the connection
		URL url = new URL(fullUrl);
		HttpURLConnection con = (HttpURLConnection) url.openConnection();

		// Set the timeout so don't wait forever
		int timeoutMsec = AvlConfig.getAvlFeedTimeoutInMSecs();
		con.setConnectTimeout(timeoutMsec);
		con.setReadTimeout(timeoutMsec);

		// Request compressed data to reduce bandwidth used
		if (useCompression)
			con.setRequestProperty("Accept-Encoding", "gzip,deflate");

		// Set any additional AVL feed specific request headers
		setRequestHeaders(con);
		
		// Create appropriate input stream depending on whether content is compressed or not
		in = con.getInputStream();
		if ("gzip".equals(con.getContentEncoding())) {
		    in = new GZIPInputStream(in);
		    logger.debug("Returned data is compressed");
		} else {
		    logger.debug("Returned data is NOT compressed");			
		}
		
		return in;
	}
	
	/**
	 * Gets, reads and processes DoubleMap stops feed.
	 * This is essential for the module to be functional, so exceptions aren't caught
	 */
	protected void readDoubleMapStopData() throws JSONException, IOException, MalformedURLException {
		IntervalTimer timer = new IntervalTimer();
		InputStream in = null;
		
		// Get from the AVL feed subclass the URL to use for this feed
		String fullUrl = stopsUrl.getValue();
		logger.info("Getting stop data from feed using url=" + stopsUrl);
		
		// Get and process the stops data
		try {
			in = getInputStream(fullUrl);
			logger.debug("Time to access inputstream {} msec", timer.elapsedMsec());

			timer.resetTimer();

			processStopData(in);
			logger.debug("Time to process stop data {} msec", timer.elapsedMsec());

		} finally {
			// Clean up regardless of whether processing was successful
	        if (in != null) {
	            try {
	                in.close();
	            } catch (IOException e) {
	                logger.error(e.getMessage());
	                e.printStackTrace();
	            }
	        }			
		}
	}

	/**
	 * Gets, reads and processes DoubleMap routes feed
	 * Catch and log exceptions that may be transient, as we'll be trying again periodically 
	 */
	protected void readDoubleMapRouteData() throws MalformedURLException {
		IntervalTimer timer = new IntervalTimer();
		InputStream in = null;

		// Get from the AVL feed subclass the URL to use for this feed
		String fullUrl = routesUrl.getValue();
		logger.info("Getting route data from feed using url=" + routesUrl);

		try {
			in = getInputStream(fullUrl);
			logger.debug("Time to access inputstream {} msec", timer.elapsedMsec());
	
			timer.resetTimer();
	
			// Clear the route lookup and rebuild it
			routeLookup.clear();
			processRouteData(in);
			logger.debug("Time to process route data {} msec", timer.elapsedMsec());
			logger.debug("routeLookup: {}", routeLookup);

		} catch (JSONException e) {
			logger.error(e.getMessage());
			e.printStackTrace();

		} catch (IOException e) {
			logger.error(e.getMessage());
			e.printStackTrace();
	
		} finally {
			// Clean up regardless of whether processing was successful
	        if (in != null) {
	            try {
	                in.close();
	            } catch (IOException e) {
	                logger.error(e.getMessage());
	                e.printStackTrace();
	            }
	        }			
		}
	}
	
	/**
	 * Build the lookup for matching DoubleMap internal stop id to GTFS stop_id
	 * 
	 * The DoubleMap stops endpoint is a JSON feed of stops that have been configured in their system.
	 * The unique id for each stop is internal to DoubleMap, but stops also contain a "code"
	 * attribute, which (should) match the GTFS stop_id. This feed is meant to be processed once per session,
	 * which in this case means when this module starts (when TheTransitClock starts)
	 * 
	 * @param in, The JSON feed
	 */
	private void processStopData(InputStream in) throws JSONException, IOException {
		String jsonStr = getJsonString(in);
		JSONArray stops = new JSONArray(jsonStr);
		
		for (int i = 0; i < stops.length(); i++) {
			JSONObject stop = stops.getJSONObject(i);
			
			// note that the DoubleMap stop "code" corresponds to the GTFS stop_id, not stop_code
			Integer id = stop.getInt("id");
			String code = stop.getString("code");

			if (code.equals(null)) {
				logger.error("Stop with DoubleMap id={}: `code` is missing or null. Not adding to lookup. stop={}", id, stop);
				continue;
			}
			
			Stop gtfsStop = Core.getInstance().getDbConfig().getStop(code);
			if (gtfsStop.equals(null)) {
				logger.error("Stop with DoubleMap id={}, code={}; no matching GTFS stop found. Not adding to lookup. stop={}", id, code, stop);
				continue;
			}

			stopLookup.put(id, code);
		}
	}

	/**
	 * Build the lookup for matching DoubleMap internal route id to GTFS route_id
	 * 
	 * The DoubleMap routes endpoint is a JSON feed of routes that have been configured in their system.
	 * The unique id for each route is internal to DoubleMap, and routes do NOT contain the GTFS route_id.
	 * The best available data to use for matching is an array of stop ids,
	 * which is used to compare to the GTFS data to try and find a best match.
	 * 
	 * The array of stop ids should be equivalent to the stop ids you would get from the GTFS stop_times
	 * data, but we don't assume that the stop ids are ordered, so we're not comparing an ordered list.
	 * Instead, we construct a Set of stop ids, convert those to GTFS stop ids, and intersect that with 
	 * the Set of GTFS stop ids for each route to find potential matches.
	 * 
	 * @param in
	 */
	private void processRouteData(InputStream in) throws JSONException, IOException {
		String jsonStr = getJsonString(in);
		JSONArray doubleMapRoutes = new JSONArray(jsonStr);

		// Create a map between all GTFS routes and the GTFS stop_ids associated with them via trips
		HashMap<Route, HashSet<String>> stopIdsByRoute = new HashMap<Route, HashSet<String>> ();
		List<Route> gtfsRoutes = Core.getInstance().getDbConfig().getRoutes();
		for (Route route : gtfsRoutes) {
			HashSet<String> stopIds = getStopIdsForRoute(route.getId());
			stopIdsByRoute.put(route, stopIds);
		}

		// Loop through the DoubleMap routes, processing them one at a time
		for (int i = 0; i < doubleMapRoutes.length(); i++) {
			// Each route has an internal DoubleMap id and an array of internal DoubleMap stop ids
			JSONObject doubleMapRoute = doubleMapRoutes.getJSONObject(i);
			Integer doubleMapRouteId = doubleMapRoute.getInt("id");
			JSONArray doubleMapStopIds = doubleMapRoute.getJSONArray("stops");

			// Convert to GTFS stop ids and find possible matching routes
			Set<String> subset = getGtfsStopIds(doubleMapStopIds);
			HashSet<Route> possibleRoutes = getPossibleRoutes(stopIdsByRoute, subset);					

			// If we found one match, we're good to go
			// Otherwise, log the errors
			if (possibleRoutes.size() == 1) {
				for (Route route : possibleRoutes) {
					logger.debug("Found single route match for DoubleMap route id = {}, GTFS route_id = {}. Adding to lookup.", 
							doubleMapRouteId, route.getId());
					routeLookup.put(doubleMapRouteId, route.getId());
				}
			} else if (possibleRoutes.size() > 1) {
				logger.error("Found multiple route matches ({}) for DoubleMap route id = {}. Not adding to lookup. possibleRoutes={}", 
						possibleRoutes.size(), doubleMapRouteId, possibleRoutes);
			} else {
				logger.error("Unable to find route match for DoubleMap route id = {}", doubleMapRouteId);
			}
		}
	}

	/**
	 * Use the stopLookup to convert DoubleMap stop ids to GTFS stop_ids and create a set of unique IDs
	 * @param doubleMapStopIds
	 * @return Set of GTFS stop_ids
	 */
	private Set<String> getGtfsStopIds(JSONArray doubleMapStopIds) {
		Set<String> gtfsStopIds = new HashSet<String>();
		for (int j = 0; j < doubleMapStopIds.length(); j++) {
			Integer doubleMapStopId = doubleMapStopIds.getInt(j);
			if (stopLookup.containsKey(doubleMapStopId)) {
				gtfsStopIds.add(stopLookup.get(doubleMapStopId));
			} else {
				logger.warn("stopLookup missing DoubleMap id {}", doubleMapStopId);
			}
		}
		
		return gtfsStopIds;
	}

	/**
	 * Compare the set of GTFS stop_ids for this DoubleMap route to each GTFS route's set of GTFS stop_ids.
	 * The GTFS route's set of stop_ids is the superset (contains all trip patterns).
	 * The DoubleMap route's set of stop_ids should be fully contained in the superset
	 * in order for this to be considered a match.
	 * 
	 * @param stopIdsByRoute
	 * @param subset
	 * @return set of possible matching routes
	 */
	private HashSet<Route> getPossibleRoutes(HashMap<Route, HashSet<String>> stopIdsByRoute, Set<String> subset) {
		HashSet<Route> possibleRoutes = new HashSet<Route>(); 
		for (Map.Entry<Route, HashSet<String>> entry : stopIdsByRoute.entrySet()) {
		    Route route = entry.getKey();
		    HashSet<String> superset = entry.getValue();
		    HashSet<String> intersection = new HashSet<String>();
		    intersection.addAll(superset);
		    intersection.retainAll(subset);
		    if (intersection.equals(subset)) {
		    	logger.debug("Found potential route match: {}", route.getId());
		    	possibleRoutes.add(route);
		    }
		}
		
		return possibleRoutes;
	}

	/**
	 * Returns the set of stop IDs for the specified route.
	 * 
	 * @param routeId
	 * @return collection of stop IDs for route
	 */
	private HashSet<String> getStopIdsForRoute(String routeId) {
		// Note: there is a similar private method in DbConfig that could be made public, but we want a HashSet not a Collection
		HashSet<String> stopIds = new HashSet<String>();
		
		List<TripPattern> tripPatternsForRoute = Core.getInstance().getDbConfig().getTripPatternsForRoute(routeId);
		for (TripPattern tripPattern : tripPatternsForRoute) {
			for (String stopId : tripPattern.getStopIds()) {
				stopIds.add(stopId);
			}
		}
		
		return stopIds;
	}

	/**
	 * Create a single AvlReport and set the assignment if possible based on the DoubleMap JSON data 
	 * @param vehicle
	 * @return AVL report
	 */
	private AvlReport createAvlReportFromDoubleMapBus(JSONObject vehicle) throws JSONException {
		logger.debug("DoubleMap bus={}", vehicle);

		// Process the data
		Integer routeId = vehicle.getInt("route");
		String vehicleId = vehicle.getString("name");
		long time = vehicle.getLong("lastUpdate") * Time.MS_PER_SEC;
		double lat = vehicle.getDouble("lat");
		double lon = vehicle.getDouble("lon");
		Float speed = Float.NaN;
		// Note: there is a "heading" field in the feed, but it is null for LYNX, so we don't have enough info yet to process it
		Float heading = Float.NaN;
		String source = vehicle.getJSONObject("fields").has("type") ? vehicle.getJSONObject("fields").getString("type") : null;

		// Create the AvlReport
		AvlReport avlReport = new AvlReport(vehicleId, time, lat, lon, speed, heading, source);

		// Set the route assignment if possible
		if (routeId.equals(null)) {
			logger.warn("Vehicle does not have an assignment, DoubleMap bus={}, avlReport={}", vehicle, avlReport);
		} else if (!routeLookup.containsKey(routeId)) {
			logger.warn("Could not find route map entry for DoubleMap routeId={}, DoubleMap bus={}, avlReport={}", routeId, vehicle, avlReport);
		} else {
			String gtfsRouteId = routeLookup.get(routeId);
			avlReport.setAssignment(gtfsRouteId, AssignmentType.ROUTE_ID);
			logger.debug("Successfully set route assignment for DoubleMap routeId={}, GTFS route_id={}, DoubleMap bus={}, avlReport={}", routeId, gtfsRouteId, vehicle, avlReport);
		}
		
		return avlReport;
	}

	/**
	 * Just for debugging
	 */
	public static void main(String[] args) {
		// For debugging turn off the actual processing of the AVL data.
		// This way the AVL data is logged, but that is all.
		shouldProcessAvl = false;

		// Create a Core so GTFS data gets loaded and cached prior to processing stops and routes
		Core.getInstance();
		
		// Create a DoubleMapAvlModule for testing
		Module.start("org.transitclock.custom.lynx.DoubleMapAvlModule");
	}
}
