<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%@include file="/template/includes.jsp" %>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Specify Parameters</title>

  <!-- Load in Select2 files so can create fancy route selector -->
  <link href="../../select2/select2.css" rel="stylesheet"/>
  <script src="../../select2/select2.min.js"></script>
  
  <link href="../params/reportParams.css" rel="stylesheet"/>

  <script>
    function execute() {
      var selectedRouteId = $("#route").val();
      var format = $('input:radio[name=format]:checked').val();
  	  var url = apiUrlPrefix + "/command/gtfs-rt/tripUpdates?format=" + format;

   	  // Actually do the API call
   	  location.href = url;
    }
  </script>
  
</head>
<body>

  <div class="mdl-layout mdl-js-layout mdl-layout--fixed-header"> 
 
    <%@include file="/template/header.jsp" %>
 
 <main class="mdl-layout__content">
	<div class="page-content">

<div class="mdl-grid">
  <div class="mdl-cell mdl-cell--3-col"></div>
  <div class="mdl-cell mdl-cell--6-col">

<div id="title" class="mdl-layout-title">
   Select Parameters for GTFS-Realtime Trip Updates API
</div>
   
<div id="mainDiv">   
   <div id="radioButtonsDiv">
     <input type="radio" name="format" value="binary" checked>Binary
     <input type="radio" name="format" value="human">Human Readable
   </div>
   
   <%-- Create submit button --%> 
   <jsp:include page="../params/submitApiCall.jsp" /> 
   
</div>

			</div>
			<div class="mdl-cell mdl-cell--3-col"></div>
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
</html>