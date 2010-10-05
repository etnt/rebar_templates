%    -*- Erlang -*- 
%    File:	rest_appmod.erl
%    Author:	Nadia Mohedano Troyano
%
%  Adapted to SimpleBridge by etnt@redhoterlang.com
%

-module({{appid}}_static_file).

-export([dispatch/1]).

-include("{{appid}}.hrl").
-include_lib("yaws/include/yaws_api.hrl").

dispatch(#controller{response = Response, cpath = CPath, path = Path})  -> 
    File = filename:join([{{appid}}:top_dir(),"www",CPath]++Path),
    {ok, Bin} = file:read_file(File),

    %% Calculate expire date far into future...
    Seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
    TenYears = 10 * 365 * 24 * 60 * 60,
    Seconds1 = calendar:gregorian_seconds_to_datetime(Seconds + TenYears),
    ExpireDate = httpd_util:rfc1123_date(Seconds1),

    {{appid}}:mk_response(Response, 200,
                       [{"Content-Type", figure_out_content_type(File)},
                        {"Expires", ExpireDate}],
                       Bin).


figure_out_content_type(Name) ->
    case lists:reverse(string:tokens(Name, ".")) of
        [X|_] -> what_content_type(X);
        _     -> what_content_type(undefined)
    end.


what_content_type("png")    -> "image/png";
what_content_type("jpg")    -> "image/jpeg";
what_content_type("jpeg")   -> "image/jpeg";
what_content_type("gif")    -> "image/gif";
what_content_type("mp3")    -> "audio/mpeg";
what_content_type("mpeg")   -> "video/mpeg";
what_content_type("avi")    -> "video/x-msvideo";
what_content_type("txt")    -> "text/plain";
what_content_type("xml")    -> "text/xml";
what_content_type("html")   -> "text/html";
what_content_type("css")    -> "text/css";
what_content_type("csv")    -> "text/x-csvpp";
what_content_type("pdf")    -> "application/pdf";
what_content_type("ps")     -> "application/postscript";
what_content_type(_)        -> "application/octet-stream".
