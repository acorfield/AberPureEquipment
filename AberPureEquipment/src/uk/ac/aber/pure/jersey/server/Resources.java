package uk.ac.aber.pure.jersey.server;

import javax.ws.rs.Path;

@Path("/service")
public class Resources {
	
	@Path("/equipment")
	public Class<EquipmentResource> getEquipmentResource() {
		return EquipmentResource.class;
	}
}
