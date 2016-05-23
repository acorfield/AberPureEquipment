Configure by updating the 3 files shown below e.g. in web.xml you configure your Pure service url (probably no
need to change 'equipments' part) which would then be something like http://pure.aber.ac.uk/ws/rest/equipments
The default ant build target is 'deploy' which requires the file path to root of servlet container (tomcat 7).

Service URLs
http://localhost:8080/pureEquipment/service/equipment/xml
http://localhost:8080/pureEquipment/service/equipment/html


webContent/WEB-INF/web.xml
  <context-param>
    <param-name>pure.resource.equipment</param-name>
    <param-value>equipments</param-value>
  </context-param>

  <context-param>
    <param-name>pure.service.url</param-name>
    <param-value>http://pure.aber.ac.uk/ws/rest</param-value>
  </context-param>

resources/log4j.properties
log4j.appender.A1.File=/pure/logs/pureEquipment.log

build.xml
<!-- deploy properties -->
<property name="servlet.container" value="/Users/awc/dev/apache/tomcat"/>