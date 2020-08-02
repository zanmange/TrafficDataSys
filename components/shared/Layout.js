import React, { Component } from 'react'
import Head from 'next/head'

class Layout extends Component {

  render () {
    return (
      <div>
        <Head>
          <title>TrafficDataSys</title>
          <meta charSet='utf-8' />
          <meta
            name='viewport'
            content='width=device-width,initial-scale=1.0,maximum-scale=1.0,minimum-scale=1,user-scalable=0,initial-scale=1'
          />
          <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
          <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
          <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png"/>
		  <link href="../assets/css/nucleo-icons.css" rel="stylesheet" />
		  <link href="../assets/css/bootstrap.min.css" rel="stylesheet" />
		  <link href="../assets/css/black-dashboard.css?v=1.0.0" rel="stylesheet" />
          <link rel="manifest" href="/site.webmanifest"></link>
		  
		  <script src="../assets/js/core/jquery.min.js"></script>
		  <script src="../assets/js/core/popper.min.js"></script>
		  <script src="../assets/js/core/bootstrap.min.js"></script>
		  <script src="../assets/js/plugins/perfect-scrollbar.jquery.min.js"></script>
		  <script src="../assets/js/plugins/chartjs.min.js"></script>
		  <script src="../assets/js/plugins/bootstrap-notify.js"></script>
		  
		  <script src="../assets/js/moment.js"></script>
		  <script src="../assets/js/moment.min.js"></script>
		  <script src="../assets/js/moment-with-locales.js"></script>
		  <script src="../assets/js/moment-with-locales.min.js"></script>
		  
		  <script src="../assets/js/black-dashboard.min.js?v=1.0.0" type="text/javascript"></script>
          <script type="text/javascript" src="/static/js/fabric.min.js" />
        </Head>
        {this.props.children}
      </div>
    )
  }
}

export default Layout
