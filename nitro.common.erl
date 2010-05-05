%% @author {{name}} {{email}}
%% @copyright YYYY {{name}}.

-module({{appid}}_common).
-include_lib ("nitrogen/include/wf.hrl").
-export([header/1
         , footer/0
         , right/0
         , left/0
        ]).


right() ->
    #panel { class=menu, body=["RIGHT"] }.


left() ->
    #panel { class=menu, body=["LEFT"] }.


header(Selected) ->
    wf:wire(Selected, #add_class { class=selected }),
    #panel { class=menu, body=[
        #link { id=home,  url='/',         text="HOME"  },
        #link { id=load,  url='/load',     text="LOAD"  },
        #link { id=about, url='/about',    text="ABOUT" }
    ]}.


footer() ->
    #panel { class=credits, body=[
        "
        Copyright &copy; 2010 <a href='http://www.redhoterlang.com'>{{name}}</a>. 
        Released under the MIT License.
        "
    ]}.

