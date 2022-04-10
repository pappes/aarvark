<!DOCTYPE html>

<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{testName}} Test</title>
    {{testScript}}


    <script async type="application/dart" src="all_test.dart"></script>
    <script async src="packages/browser/dart.js"></script>
    <script id=script_x async src="packages/browser/x.js"></script>
    <script id=script_y async src="packages/browser/y.js"></script>
    <script id=script_z async src="packages/browser/z.js"></script>

    <script src="packages/test/dart.js"></script>
    
  </head>
  <body>


    <h1>IFrame Testing</h1>
    
    <p id=inside_p>Page for testing iframe DART code in the pappes_web_utility library</p>
    
    <a id=inside_anchor_text href=http://www.abc.com/noredirect?u=realurl_com>
    Non-redirect URL</a><br>
    <a id=inside_anchor_button href=http://www.abc.com/redirect?u=www.realurl.com></a><br>
    
    
    <frameset cols="25%,50%,25%">
      <frame id=inside_frame_a src="inside_frame_a.htm">
    </frameset>


    <h1>pappes_web_utility Testing</h1>
    
    <p>Page for testing DART myHtml code in the pappes_web_utility library</p>
    
    <a id=non_redirect href=http://www.abc.com/noredirect?u=realurl_com>
    Non-redirect URL</a><br>
    <a id=redirect_simple_www href=http://www.abc.com/redirect?u=www.realurl.com>
    Simple www redirect URL</a><br>
    <a id=redirect_simple_http href=http://www.abc.com/redirect?u=http://www.realurl.com>
    Simple http redirect URL</a><br>
    <a id=redirect_simple_http_dir href=http://www.abc.com/redirect?u=http://www.realurl.com/target/>
    Simple http redirect URL with directories</a><br>
    <a id=redirect_http_param href=http://www.abc.com/redirect?u=http://www.realurl.com/target/?x=y&a=b>
    http redirect URL with params</a><br>
    <a id=redirect_http_fake_param href=http://www.abc.com/redirect?u=http://www.realurl.com/target/&x=y&a=b>
    http redirect URL without params</a><br>
    <a id=redirect_http_url_encode href=http://www.abc.com/redirect?u=http%3A%2F%2Fwww.realurl.com%2Ftarget%2F>
    http redirect URL with URL encoding</a><br>
    <a id=redirect_http_url_encode_param href=http://www.abc.com/redirect?u=http%3A%2F%2Fwww.realurl.com%2Ftarget%2F%3Fx%3Dy%26a%3Db>
    http redirect URL with URL encoding and params</a><br>
    <a id=redirect_http_fake_b64_encode href=http://www.abc.com/redirect?l=YTo5OntzOjE6ImMiO2k6MTtzOjM6InNpZCI7aToxNTU5O3M6MzoiaWlkIjtpOjQ5O3M6MjoiaXQiO3M6MjoiaWMiO3M6MzoiZ2lkIjtzOjc6Ijc4NzU1NzAiO3M6NDoia3dpZCI7aTo1ODY5O3M6NDoiY3NpZCI7czozOiIzNTkiO3M6MzoicG9zIjtpOjE7czoyOiJycyI7aToxMTt9&u=http://www.realurl.com/target/?x=y&a=b>
    http redirect URL with fake base64 payload and URL params</a><br>
    <a id=redirect_http_fake_b64_encode_param href=http://www.abc.com/redirect?l=YTo5OntzOjE6ImMiO2k6MTtzOjM6InNpZCI7aToxNTU5O3M6MzoiaWlkIjtpOjQ5O3M6MjoiaXQiO3M6MjoiaWMiO3M6MzoiZ2lkIjtzOjc6Ijc4NzU1NzAiO3M6NDoia3dpZCI7aTo1ODY5O3M6NDoiY3NpZCI7czozOiIzNTkiO3M6MzoicG9zIjtpOjE7czoyOiJycyI7aToxMTt9&u=http%3A%2F%2Fwww.realurl.com%2Ftarget%2F%3Fx%3Dy%26a%3Db>
    http redirect URL with fake base64 payload URL encoding and params</a><br>
    
    <a id=redirect_http_b64_encode href=http://www.abc.com/redirect?l=aHR0cDovL3d3dy5yZWFsdXJsLmNvbS90YXJnZXQvP2M9ZCZlPTEyMw==>
    http redirect URL with real base64 payload</a><br>
    <a id=redirect_http_b64_encode_param href=http://www.abc.com/redirect?l=aHR0cDovL3d3dy5yZWFsdXJsLmNvbS90YXJnZXQvP2M9ZCZlPTEyMw==&x=y&a=b>
    http redirect URL with real base64 payload and fake params</a><br>
    
    
    <a id=no_target href=http://www.abc.com/noredirect?u=realurl_com>
    No target URL</a><br>
    <a id=_blank_target href=http://www.abc.com/noredirect?u=realurl_com target="_blank">
    Blank target URL</a><br>
    <a id=_parent_target href=http://www.abc.com/noredirect?u=realurl_com target="_parent">
    Parent target URL</a><br>
    <a id=_self_target href=http://www.abc.com/noredirect?u=realurl_com target="_self">
    Self target URL</a><br>
    <a id=_top_target href=http://www.abc.com/noredirect?u=realurl_com target="_top">
    Top target URL</a><br>
    <a id=frame_target href=http://www.abc.com/noredirect?u=realurl_com target="frame_a">
    Frame target URL</a><br>
    
    <p id=outside_p>Page for testing DART code in the pappes_web_utility library</p>
    
    <a id=outside_anchor_text href=http://www.abc.com/noredirect?u=realurl_com>
    Non-redirect URL</a><br>
    <a id=outside_anchor_button href=http://www.abc.com/redirect?u=www.realurl.com></a><br>
    <iframe id=outside_iframe src=pappes_web_utility_myhtml_iframe_test.html></iframe><br>
    
    <frameset cols="25%,50%,25%">
      <frame id=outside_frame_a src="frame_a.htm">
      <frame id=frame_a src="frame_a.htm">
      <frame id=frame_b src="frame_b.htm">
      <frame id=frame_c src="frame_c.htm">
    </frameset>

  </body>
</html>
