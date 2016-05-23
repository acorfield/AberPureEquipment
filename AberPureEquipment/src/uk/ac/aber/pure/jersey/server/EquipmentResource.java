package uk.ac.aber.pure.jersey.server;

import java.io.File;

import javax.inject.Singleton;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Response;

import uk.ac.aber.pure.jersey.InitParameters;
import uk.ac.aber.pure.jersey.client.PureEquipmentService;

@Singleton
public class EquipmentResource extends AbstractResource {
	
	@GET
	@Path("/xml")
	@Produces("text/xml")
	public Response getXml() {
		key = "equipment-xml";
		fileType= "xml";
		styleSheet = InitParameters.getString(InitParameters.STYLESHEET_EQUIPMENT_XML);
		File file = process(this, new PureEquipmentService());				
		return Response.ok(file).build();
	}

	@GET
	@Path("/html")
	@Produces("text/html")
	public Response getHtml() {
		key = "equipment-html";
		fileType= "html";
		styleSheet = InitParameters.getString(InitParameters.STYLESHEET_EQUIPMENT_HTML);		
		File file = process(this, new PureEquipmentService());		
		return Response.ok(file).build();
	}
} 