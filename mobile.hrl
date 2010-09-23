-ifndef(_{{appid}}_HRL).
-define(_{{appid}}_HRL, true).

-define(SUPPORTED_MEDIA, [ "application/xhtml+xml", 
                           "application/xml", 
                           "application/json"]).
-define(CT, "Content-Type").
-define(COUNTRY_CACHE, -1).
-define(CHARSET, "charset=iso-8859-1").
-define(REST_FILE(File), 
        filename:join({{appid}}:docroot(),"/rest/") ++ File).


-record(controller, 
        {request,
         response,
         content_type,
         path,
         method
        }).


-endif.
