package org.transitclock.api.data;

import java.lang.reflect.InvocationTargetException;
import java.util.Date;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;

import org.transitclock.ipc.data.IpcArrivalDeparture;

@XmlRootElement(name = "arrivaldeparture")
public class ApiArrivalDeparture {
	
	@XmlAttribute
	private String vehicleId;
	@XmlAttribute
	private Date time;
	@XmlAttribute
	private String stopId;
	@XmlAttribute
	private int gtfsStopSeq;
	@XmlAttribute
	private boolean isArrival;
	@XmlAttribute
	private String tripId;
	@XmlAttribute
	private Date avlTime;
	@XmlAttribute
	private Date scheduledTime;
	@XmlAttribute
	private String blockId;
	@XmlAttribute
	private String routeId;
	@XmlAttribute
	private String routeShortName;
	@XmlAttribute
	private String serviceId;
	@XmlAttribute
	private String directionId;
	@XmlAttribute
	private int stopPathIndex;

	/**
	 * Need a no-arg constructor for Jersey. Otherwise get really obtuse
	 * "MessageBodyWriter not found for media type=application/json" exception.
	 */
	protected ApiArrivalDeparture() {
	}
	
	public ApiArrivalDeparture(IpcArrivalDeparture ipcArrivalDeparture) throws IllegalAccessException, InvocationTargetException {
		this.vehicleId=ipcArrivalDeparture.getVehicleId();
		this.time=ipcArrivalDeparture.getTime();
		this.stopId=ipcArrivalDeparture.getStopId();
		this.gtfsStopSeq=ipcArrivalDeparture.getGtfsStopSeq();
		this.isArrival=ipcArrivalDeparture.isArrival();
		this.tripId=ipcArrivalDeparture.getTripId();
		this.avlTime=ipcArrivalDeparture.getAvlTime();
		this.scheduledTime=ipcArrivalDeparture.getScheduledTime();
		this.blockId=ipcArrivalDeparture.getBlockId();
		this.routeId=ipcArrivalDeparture.getRouteId();
		this.routeShortName=ipcArrivalDeparture.getRouteShortName();
		this.serviceId=ipcArrivalDeparture.getServiceId();
		this.directionId=ipcArrivalDeparture.getDirectionId();
		this.stopPathIndex=ipcArrivalDeparture.getStopPathIndex();
	}

}
