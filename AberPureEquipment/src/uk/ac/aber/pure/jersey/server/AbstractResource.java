package uk.ac.aber.pure.jersey.server;

import java.io.File;

import javax.ws.rs.WebApplicationException;

import org.apache.log4j.Logger;

import uk.ac.aber.pure.jersey.client.PureService;
import uk.ac.aber.pure.transform.XMLFileProcessor;

public class AbstractResource {
	private static final Logger log = Logger.getLogger(AbstractResource.class);

	protected String styleSheet;
	protected String fileType;
	protected String key;
	
	protected File process(AbstractResource resource, PureService pureService) {
		
		try {			
			XMLFileProcessor xmlFileProcessor = new XMLFileProcessor();
			synchronized (resource) {
				return xmlFileProcessor.process(this, pureService);
			}
		} catch (Exception e) {
			log.error("Internal server Error!", e);
		    throw new WebApplicationException(404);
		}
	}	
	
	public String getStyleSheet() {
		return styleSheet;
	}
	
	public String getFileType() {
		return fileType;
	}
	
	public String getKey() {
		return key;
	}
}
