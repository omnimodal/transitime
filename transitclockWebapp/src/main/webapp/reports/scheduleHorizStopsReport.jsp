<%-- Displays the schedule for a route--%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="org.transitclock.utils.web.WebUtils" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
String agencyId = request.getParameter("a");
if (agencyId == null || agencyId.isEmpty()) {
    response.getWriter().write("You must specify agency in query string (e.g. ?a=mbta)");
    return;
}
%>
<html>
<head>
  <%@include file="/template/includes.jsp" %>
    
  <style>
  #scheduleTitle {
  	font-size: x-large;
  	margin-top: 30px;
  	margin-bottom: 6px;
  	text-align: center;
  }

  #dataTable {
	font-size: 8pt;
    text-align: center;
  }
    
  #headerCell {
  	font-weight: bold;
  	background-color: #F2F5F7;
  }
  
  </style>
  
  <script type="text/javascript" src="https://www.google.com/jsapi"></script>
  
  <script type="text/javascript">
      function dataReadCallback(jsonData) {
	      // Set the title now that have the route name from the API
	      $('#title').html('Schedule for ' + jsonData.routeName);
	      
	      // Go through all service classes and directions for route
    	  for (var i=0; i<jsonData.schedule.length; ++i) {
    		  var schedule = jsonData.schedule[i];
    		  
    		  // Create title for schedule
    		  $('#report').append("<div id='scheduleTitle'>" 
    				  + "Direction: " + schedule.directionId 
    				  + ", Service: " + schedule.serviceName
    				  + "</div>");

    		  var table = $("<table id='dataTable'></table>").appendTo('#report')[0];
    		  
    		  // Create the columns for the header. First column is stop name. And then there
    		  // is one column per trip.
    		  var headerRow = table.insertRow(0);
    		  headerRow.insertCell(0).id = 'headerCell';
    		  for (var j=0; j<schedule.stop.length; ++j) {
    			  var stop = schedule.stop[j];
    			  var headerCell = headerRow.insertCell(j+1);
    			  headerCell.id = 'headerCell';
    			  headerCell.innerHTML = stop.stopName;
    		  }

    		  // Add data for each row for the schedule. This is a bit complicated
    		  // because the API provides data per trip but want each row in the
    		  // schedule to be for a particular stop for all trips.
    		  for (var tripIdx=0; tripIdx<schedule.timesForTrip.length; ++tripIdx) {
        		  var row = table.insertRow(tripIdx+1);
        		  var timesForTrip = schedule.timesForTrip[tripIdx];

        		  // Add block/trip info to row
                  var tripName = timesForTrip.tripShortName;
                  if (tripName == null)
                      tripName = timesForTrip.tripId;
                  var tripNameTooLong = tripName.length > 6;
                  var html = tripNameTooLong ?
                      "Block&nbsp;" + timesForTrip.blockId : "Trip&nbsp;" + tripName;
                  var headerCell = row.insertCell(0);
                  headerCell.id = 'headerCell';
                  headerCell.innerHTML = html;
        		  
        		  // Add the times for the stop to the row
                  for (var stopIdx=0; stopIdx<timesForTrip.time.length; ++stopIdx) {    				  
                      var time = timesForTrip.time[stopIdx];
                      row.insertCell(stopIdx+1).innerHTML = time.timeStr ? time.timeStr : '';
                  }
    		  }    		  
    	  }
      }
      
      $( document ).ready(function() {
    	  $.ajax({
    	      	// The page being requested
    		  	url: apiUrlPrefix + "/command/scheduleHorizStops",
    	      	// Pass in query string parameters to page being requested
    	      	data: {<%= WebUtils.getAjaxDataString(request) %>},
    	    	// Needed so that parameters passed properly to page being requested
    	    	traditional: true,
    	        dataType:"json",
				success: dataReadCallback
    	  });
      });
            
  </script>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Schedule Report</title>
</head>
<body>
  <div class="mdl-layout mdl-js-layout mdl-layout--fixed-header"> 
 
    <%@include file="/template/header.jsp" %>
 
 <main class="mdl-layout__content">
	<div class="page-content">

<div class="mdl-grid">
  <div class="mdl-cell mdl-cell--12-col">

<div id="title" class="mdl-layout-title"></div>
<div id="report"></div>

			</div>
		</div>
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
