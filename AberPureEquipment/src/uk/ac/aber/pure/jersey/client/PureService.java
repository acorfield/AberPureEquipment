package uk.ac.aber.pure.jersey.client;

import java.io.InputStream;

public interface PureService {
	public InputStream getXml(Integer windowOffset);
	public InputStream getXmlCount();
}
