<%@page import="org.transitclock.db.webstructs.WebAgency"%>
<%@page import="java.util.Collection"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!doctype html>
<html lang="en">
<head>
  <%@include file="/template/includes.jsp" %>
  
  <title>Agencies</title>
</head>

<body>

<div class="mdl-layout mdl-js-layout mdl-layout--fixed-header">

<%@include file="/template/header.jsp" %>

<main class="mdl-layout__content">
	<div class="page-content">

<%
// Output links for all the agencies
Collection<WebAgency> webAgencies = WebAgency.getCachedOrderedListOfWebAgencies();
for (WebAgency webAgency : webAgencies) {
	// Only output active agencies
	if (!webAgency.isActive())
		continue;
	%>

<h2><%= webAgency.getAgencyName() %></h2>

<div class="demo-card-square mdl-card mdl-shadow--2dp">
  <div class="mdl-card__title mdl-card--expand">
    <h2 class="mdl-card__title-text">Maps</h2>
  </div>
  <div class="mdl-card__supporting-text">
    Real-time maps
  </div>
  <div class="mdl-card__actions mdl-card--border">
    <a class="mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect" href="<%= request.getContextPath() %>/maps/map.jsp?verbose=true&a=<%= webAgency.getAgencyId() %>&showUnassignedVehicles=true">
      Live Map
    </a>
    <a class="mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect" href="<%= request.getContextPath() %>/maps/schAdhMap.jsp?a=<%= webAgency.getAgencyId() %>">
      Schedule Adherence Map
    </a>
    <a class="mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect" href="<%= request.getContextPath() %>/reports/avlMap.jsp?a=<%= webAgency.getAgencyId() %>">
      Playback Map
    </a>
  </div>
</div>

<div class="demo-card-square mdl-card mdl-shadow--2dp">
  <div class="mdl-card__title mdl-card--expand">
    <h2 class="mdl-card__title-text">Reports</h2>
  </div>
  <div class="mdl-card__supporting-text">
    Reports on historic information
  </div>
  <div class="mdl-card__actions mdl-card--border">
    <a class="mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect" href="<%= request.getContextPath() %>/reports/predAccuracyIntervalsParams.jsp?a=<%= webAgency.getAgencyId() %>">
      Prediction Accuracy
    </a>
    <a class="mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect" href="<%= request.getContextPath() %>/reports/schAdhByRouteParams.jsp?a=<%= webAgency.getAgencyId() %>">
      Schedule Adherence
    </a>
    <a class="mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect" href="<%= request.getContextPath() %>/status/activeBlocks.jsp?a=<%= webAgency.getAgencyId() %>">
      Active Blocks
    </a>
  </div>
</div>

<div class="demo-card-square mdl-card mdl-shadow--2dp">
  <div class="mdl-card__title mdl-card--expand">
    <h2 class="mdl-card__title-text">Miscellaneous</h2>
  </div>
  <div class="mdl-card__supporting-text">
    Timetables
  </div>
  <div class="mdl-card__actions mdl-card--border">
    <a class="mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect" href="<%= request.getContextPath() %>/reports/scheduleHorizStopsParams.jsp?a=<%= webAgency.getAgencyId() %>">
      Schedule Timetables
    </a>
    <a class="mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect" href="<%= request.getContextPath() %>/reports/apiCalls/gtfsRealtimeVehiclePositionsApiParams.jsp?a=<%= webAgency.getAgencyId() %>">
      GTFS Realtime Vehicle Positions
    </a>
    <a class="mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect" href="<%= request.getContextPath() %>/reports/apiCalls/gtfsRealtimeTripUpdatesApiParams.jsp?a=<%= webAgency.getAgencyId() %>">
      GTFS Realtime Trip Updates
    </a>
  </div>
</div>


	<%
}
%>


<%-- <div id="mainDiv">
<div id="title">Agencies</div>
<table id="agencyList">
<%
// Output links for all the agencies
Collection<WebAgency> webAgencies = WebAgency.getCachedOrderedListOfWebAgencies();
for (WebAgency webAgency : webAgencies) {
	// Only output active agencies
	if (!webAgency.isActive())
		continue;
	%>
	<tr>
	  <td><div id=agencyName><%= webAgency.getAgencyName() %></div></td>
	  <td><a href="<%= request.getContextPath() %>/maps/index.jsp?a=<%= webAgency.getAgencyId() %>" title="Real-time maps">Maps</a></td>
	  <td><a href="<%= request.getContextPath() %>/reports/index.jsp?a=<%= webAgency.getAgencyId() %>" title="Reports on historic information">Reports</a></td>
	  <td><a href="<%= request.getContextPath() %>/reports/apiCalls/index.jsp?a=<%= webAgency.getAgencyId() %>" title="API calls">API</a></td>
	  <td><a href="<%= request.getContextPath() %>/status/index.jsp?a=<%= webAgency.getAgencyId() %>" title="Pages showing current status of system">Status</a></td>
	  <td><a href="<%= request.getContextPath() %>/extensions/index.jsp?a=<%= webAgency.getAgencyId() %>" title="Page of links to extension to the system">Extensions</a></td>
	</tr>
	<%
}
%>
</table>

</div>
 --%>

		</div>
	</main>

<footer class="mdl-mini-footer">
  <div class="mdl-mini-footer__left-section">
    <div class="mdl-logo">TheTransitClock Organization</div>
    <ul class="mdl-mini-footer__link-list">
      <li><a href="#">Help</a></li>
      <li><a href="#">Privacy & Terms</a></li>
    </ul>
  </div>
</footer>

</div>


<script src="https://cdnjs.cloudflare.com/ajax/libs/material-design-lite/1.3.0/material.min.js"></script>

</body>
</html>