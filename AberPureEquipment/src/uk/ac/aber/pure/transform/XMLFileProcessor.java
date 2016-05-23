package uk.ac.aber.pure.transform;

import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Path;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import org.apache.log4j.Logger;

import uk.ac.aber.pure.jersey.client.PureService;
import uk.ac.aber.pure.jersey.server.AbstractResource;
import uk.ac.aber.pure.jersey.InitParameters;

public class XMLFileProcessor {
    public static final String PURE_XML_FILES_SELECT = "?select=";
    public static final String PURE_XML_FILES_PREFIX = "pure";
    public static final String PURE_XML_FILES_SUFFIX = ".xml";
    public static final String PURE_XML_FILES_XML_REGX = "*" + PURE_XML_FILES_SUFFIX;
    
	private static final Logger log = Logger.getLogger(XMLFileProcessor.class);

	private FileHandler fileHandler;
    private XMLTransformer xmlTransformer;
        
	public XMLFileProcessor() {		
        fileHandler = new FileHandler();
        xmlTransformer = new XMLTransformer();
	}

	public File process(AbstractResource resource, PureService pureService) throws Exception {       	
		Path tempDirPath, tempFilePath;   		
		String prefix = getTempFilePrefix(resource);
		String suffix = getTempFileSuffix(resource); 
    		
		log.info("Processing request key " + prefix);

		tempDirPath = fileHandler.getTempDir(prefix);
		if (tempDirPath == null) {
			tempDirPath = getPureXmlFiles(pureService, prefix);
    		tempFilePath = getTransformResult(resource, tempDirPath, prefix, suffix);
		} else {
			tempFilePath = fileHandler.getTempFile(tempDirPath, prefix, suffix);
		}
		
		log.info("Writing response for key " + prefix);
		return tempFilePath.toFile();
    }
	
	private Path getPureXmlFiles(PureService pureService, String prefix) throws Exception {
		Path tempDirPath = fileHandler.getTempDir(prefix);
		if (tempDirPath == null) {
			//get number of records
			Integer count = getCount(pureService);
			//create new temp directory for xml files
			tempDirPath = fileHandler.getNewTempDir(prefix);		
	    	//get xml and save to temp directory
			log.info("Calling Pure service for key " + prefix + " (count = " + count + ")");
	    	for (int offset = 0; offset < count; offset += InitParameters.getInteger(InitParameters.PURE_SERVICE_WINDOW_SIZE_VALUE)) {  
	            Path xmlFile = fileHandler.getNewTempFile(tempDirPath, getPureXmlFilePrefix(prefix), PURE_XML_FILES_SUFFIX);
	            fileHandler.writeToFile(pureService.getXml(offset), xmlFile);                  
	    	}
		}
		return tempDirPath;
	}
	
	private Path getTransformResult(AbstractResource resource, Path tempDirPath, String prefix, String suffix) throws Exception {
		Map<String, String> params = getTransformParams(tempDirPath, prefix);
		Path tempFilePath = fileHandler.getNewTempFile(tempDirPath, prefix, suffix);
		log.info("Transforming xml for key " + prefix);
		//transform xml files, write to tempFilePath				
		transform(params, resource.getStyleSheet(), tempFilePath);
		return tempFilePath;
	}
	
	private Map<String, String> getTransformParams(Path tempDirPath, String prefix) {  	
    	Map<String, String> map = new HashMap<String, String>();
		map.put(XMLTransformer.DATE, new Date(System.currentTimeMillis()).toString());
		map.put(XMLTransformer.FILES_PARAM, getPureXmlFilesUri(tempDirPath, prefix));
		map.put(XMLTransformer.KEY, prefix);
    	return map;    	
    }
    
    private void transform(Map<String, String> params, String StyleSheetKey, Path tempFile) throws Exception {	
		//dummy InputStream required for transformer. XML files retrieved via collection function in stylesheet
       	InputStream in = fileHandler.getUrlInputStream(
    			InitParameters.getString(InitParameters.PURE_SERVICE_URL) + '/' + InitParameters.getString(InitParameters.PURE_RESOURCE_EQUIPMENT));
		OutputStream out = fileHandler.getOutputStream(tempFile);
    	try {
			xmlTransformer.transform(params, StyleSheetKey, in, out);
    	} finally {
			in.close();
			out.close();
		}
	}

    private Integer getCount(PureService pureService) throws Exception {
    	InputStream in = pureService.getXmlCount();
    	OutputStream out = fileHandler.getOutputStream();
    	
        xmlTransformer.transform(InitParameters.getString(InitParameters.STYLESHEET_COUNT_XML), in, out);
         try {
            return Integer.parseInt(out.toString());
        } catch (NumberFormatException e) {
		    log.error("Cannot parse Integer count", e);
		    return 0;
		} finally {
			in.close();
			out.close();
		}
    }    
   
    private String getTempFilePrefix(AbstractResource resource) {    		
    	return resource.getKey();
    }
    
    private String getTempFileSuffix(AbstractResource resource) {
    	return '.' + resource.getFileType();
    }
    
    private String getPureXmlFilePrefix(String prefix) {    		
    	return PURE_XML_FILES_PREFIX + '-' + prefix;
    }
    
    private String getPureXmlFilesUri(Path tempDirPath, String prefix) {
		return tempDirPath.toUri().toString() + PURE_XML_FILES_SELECT + getPureXmlFilePrefix(prefix) + PURE_XML_FILES_XML_REGX;
	}
}