surl="http://localhost:8010/SLIDS/WarmUp.aspx"


'assumed msxml2 core service well installed
set oxmlhttp=createobject("msxml2.xmlhttp")
with oxmlhttp
    .open "get",surl,false
    .setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
    .send null
end with

set oxmlhttp=nothing  
 

