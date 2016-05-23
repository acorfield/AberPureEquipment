package uk.ac.aber.pure.transform;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.log4j.Logger;

public class XMLTransformer {
	//params for stylesheet
	public static final String FILES_PARAM = "tempFilesUri";  
	public static final String COUNT_PARAM = "count";
    public static final String LOCALE_PARAM = "locale";
	public static final String DATE = "date";
	public static final String KEY = "key";

	private static final Logger log = Logger.getLogger(XMLTransformer.class);

	private static TransformerFactory defaultFactory;
	private static HashMap<String, Transformer> transformers;
	
	static {
		XMLTransformer.transformers = new HashMap<String, Transformer>();
        defaultFactory = TransformerFactory.newInstance();     
        log.debug("Java home: " + System.getProperty("java.home"));
        log.debug("TransformerFactory: " + defaultFactory.getClass().toString());   
	}

	public void transform(Map<String, String> params, String styleSheetKey, InputStream in, OutputStream out) throws TransformerConfigurationException, TransformerException {	
        StreamSource xmlSource = new StreamSource(in);
        StreamResult transformResult = new StreamResult(out);
        
        Transformer transformer =  getTransformer(styleSheetKey);
		synchronized (transformer) {
			setParameters(params, transformer);
			transform(transformer, xmlSource, transformResult);
		}
	}
	
	public void transform(String styleSheetKey, InputStream in, OutputStream out) throws TransformerConfigurationException, TransformerException {
        StreamSource xmlSource = new StreamSource(in);
        StreamResult transformResult = new StreamResult(out);
        
        Transformer transformer = getTransformer(styleSheetKey);
		synchronized (transformer) {
			transform(transformer, xmlSource, transformResult);
		}
	}
	
	private void transform(Transformer transformer, StreamSource xmlSource, StreamResult transformResult) throws TransformerException {
		
        try {
			transformer.transform(xmlSource, transformResult);
		} finally {
			if (transformer != null)
				transformer.reset();
		}	
	}
	
	private Transformer getTransformer(String styleSheetKey) throws TransformerConfigurationException {
	    
		if (transformers.containsKey(styleSheetKey)) {
			return transformers.get(styleSheetKey);
		} else {
			return loadTransformer(styleSheetKey);
		}
	}

	private Transformer loadTransformer(String styleSheetKey) throws TransformerConfigurationException {   
		log.debug("Loading style sheet " + styleSheetKey);
		
	    ClassLoader classLoader = this.getClass().getClassLoader();
	    StreamSource styleSource = new StreamSource(classLoader.getResourceAsStream(styleSheetKey));
        try {
        	transformers.put(styleSheetKey, defaultFactory.newTransformer(styleSource));
			return transformers.get(styleSheetKey);
		} catch (TransformerConfigurationException e) {
			log.error("Failed to load styleSheet " + styleSheetKey, e);
			throw e;
		}
	}
	
	private void setParameters(Map<String, String> params, Transformer transformer) {
		Iterator<Map.Entry<String, String>> it = params.entrySet().iterator();
		while (it.hasNext()) {
			Map.Entry<String, String> me = (Map.Entry<String, String>) it.next();
			transformer.setParameter(me.getKey(), me.getValue());
			log.debug("paramName " + me.getKey() + "; " + "paramValue " + me.getValue());
		}
	}
}
