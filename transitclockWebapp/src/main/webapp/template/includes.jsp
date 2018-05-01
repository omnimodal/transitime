<%-- This file contains includes that can be included with every file --%>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="description" content="A front-end template that helps you build fast, modern mobile web apps.">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0">
    <title>TheTransitClock - Hosted by Omni</title>

    <!-- Add to homescreen for Chrome on Android -->
    <meta name="mobile-web-app-capable" content="yes">
    <link rel="icon" sizes="192x192" href="images/android-desktop.png">

    <!-- Add to homescreen for Safari on iOS -->
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta name="apple-mobile-web-app-title" content="Material Design Lite">
    <link rel="apple-touch-icon-precomposed" href="images/ios-desktop.png">

    <!-- Tile icon for Win8 (144x144 + tile color) -->
    <meta name="msapplication-TileImage" content="images/touch/ms-touch-icon-144x144-precomposed.png">
    <meta name="msapplication-TileColor" content="#3372DF">

    <link rel="shortcut icon" href="images/favicon.png">

    <!-- SEO: If your mobile URL is different from the desktop URL, add a canonical link to the desktop page https://developers.google.com/webmasters/smartphone-sites/feature-phones -->
    <!--
    <link rel="canonical" href="http://www.example.com/">
    -->

    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:regular,bold,italic,thin,light,bolditalic,black,medium&amp;lang=en">
    <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/material-design-lite/1.3.0/material.cyan-light_blue.min.css">
    
<%-- Load in JQuery --%>
<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>

<%-- Load in JQuery UI javascript and css to set general look and feel, such as for tooltips --%>
<script src="<%= request.getContextPath() %>/jquery-ui/jquery-ui.js"></script>
<link rel="stylesheet" href="<%= request.getContextPath() %>/jquery-ui/jquery-ui.css">

<%-- Load in Transitime css and javascript libraries. Do this after jquery files
     loaded so can override those parameters as necessary. --%>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/general.css">
<script src="<%= request.getContextPath() %>/javascript/transitime.js"></script>

<script>

// This needs to match the API key in the database
//var apiKey = "f78a2e9a"
 var apiKey="<%=System.getProperty("transitclock.apikey")%>"
// For accessing the api for an agency command
var apiUrlPrefixAllAgencies = "/api/v1/key/" + apiKey;
var apiUrlPrefix = apiUrlPrefixAllAgencies + "/agency/<%= request.getParameter("a") %>";
</script>
