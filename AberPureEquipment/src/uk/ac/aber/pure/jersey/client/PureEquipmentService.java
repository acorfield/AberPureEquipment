package uk.ac.aber.pure.jersey.client;

import java.io.InputStream;

import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;

import uk.ac.aber.pure.jersey.InitParameters;

public class PureEquipmentService implements PureService {
	private static WebTarget webTarget;

	static {
		webTarget = ClientBuilder.newClient()
		.target(InitParameters.getString(InitParameters.PURE_SERVICE_URL))
        .path(InitParameters.getString(InitParameters.PURE_RESOURCE_EQUIPMENT))
		.queryParam(InitParameters.getString(InitParameters.PURE_SERVICE_RENDER_PARAM), InitParameters.getString(InitParameters.PURE_SERVICE_RENDER_VALUE));

	}
	
	public InputStream getXml(Integer windowOffset) {
		clearQueryParams();		

		return webTarget
			.queryParam(InitParameters.getString(InitParameters.PURE_SERVICE_WINDOW_OFFSET_PARAM), windowOffset)
			.queryParam(InitParameters.getString(InitParameters.PURE_SERVICE_WINDOW_SIZE_PARAM), InitParameters.getString(InitParameters.PURE_SERVICE_WINDOW_SIZE_VALUE))
			.request(MediaType.TEXT_XML)
			.get(InputStream.class);
	}

	public InputStream getXmlCount() {
		clearQueryParams();
		
		return webTarget
			.queryParam(InitParameters.getString(InitParameters.PURE_SERVICE_WINDOW_OFFSET_PARAM), 0)
			.queryParam(InitParameters.getString(InitParameters.PURE_SERVICE_WINDOW_SIZE_PARAM), 0)
			.request(MediaType.TEXT_XML)
            .get(InputStream.class);
	}
	
	private void clearQueryParams() {
		//clear previous query parameters
		webTarget
		.queryParam(InitParameters.getString(InitParameters.PURE_SERVICE_WINDOW_OFFSET_PARAM), ((Object[])null))
		.queryParam(InitParameters.getString(InitParameters.PURE_SERVICE_WINDOW_SIZE_PARAM), ((Object[])null));
	}
}
