(this["webpackJsonplusion-magic"]=this["webpackJsonplusion-magic"]||[]).push([[0],[,,,function(e){e.exports=JSON.parse('{"test_write":"yay!"}')},,function(e,n,t){e.exports=t(12)},,,,,function(e,n,t){},function(e,n,t){},function(e,n,t){"use strict";t.r(n);var a=t(0),r=t.n(a),l=t(2),o=t.n(l),c=(t(10),t(4)),i=(t(11),t(3)),s=window.require("electron").remote.require("fs");var m=function(){var e=Object(a.useState)(navigator.onLine),n=Object(c.a)(e,2),t=n[0],l=n[1],o=function(){l(navigator.onLine)};window.addEventListener("online",o),window.addEventListener("offline",o);var m=new URLSearchParams(window.location.search),u=!!parseInt(m.get("d"),10);console.log("userConfig",i);var d=JSON.stringify({test_write:"yay!"},null,"\t"),w=u?"./src/user_config.json":"./build/user_config.json";return s.writeFile(w,d,(function(e){if(e)throw e})),r.a.createElement("div",{className:"wrapper"},r.a.createElement("div",{className:"container row info"},r.a.createElement("div",{className:"col c1"},r.a.createElement("p",null,"info here.."))),r.a.createElement("div",{className:"container row top"},r.a.createElement("div",{className:"col c2"},r.a.createElement("p",null,"Prod: ",u?"false":"true"),r.a.createElement("p",null,"Online: ",t?"true":"false"),r.a.createElement("p",null,"..."),r.a.createElement("p",null,"..."),r.a.createElement("p",null,"..."),r.a.createElement("p",null,"...")),r.a.createElement("div",{className:"col c3"},r.a.createElement("p",null,"top right"))),r.a.createElement("div",{className:"container row middle"},r.a.createElement("div",{className:"col c4"},r.a.createElement("p",null,"middle"))),r.a.createElement("div",{className:"container row bottom"},r.a.createElement("div",{className:"col c5"},r.a.createElement("p",null,"bottom"))))};Boolean("localhost"===window.location.hostname||"[::1]"===window.location.hostname||window.location.hostname.match(/^127(?:\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$/));o.a.render(r.a.createElement(m,null),document.getElementById("lusion")),"serviceWorker"in navigator&&navigator.serviceWorker.ready.then((function(e){e.unregister()}))}],[[5,1,2]]]);
//# sourceMappingURL=main.5e6dd658.chunk.js.map