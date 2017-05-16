package uk.ac.aber.pure.jersey;

import java.io.File;
import java.io.IOException;
import java.util.Enumeration;
import java.util.HashMap;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import org.apache.log4j.Logger;

public class JerseyServletContext implements ServletContextListener {
	private static final Logger log = Logger.getLogger(JerseyServletContext.class);
	
	@Override
	public void contextInitialized(ServletContextEvent sce) {
        log.info("Servlet startup");        
        HashMap<String, String> params = new HashMap<String, String>();
        
        ServletContext servletContext = sce.getServletContext();        
        Enumeration<String> paramNames = servletContext.getInitParameterNames();
        while (paramNames.hasMoreElements()) {
        	String paramName = paramNames.nextElement();
        	String paramValue = servletContext.getInitParameter(paramName);
        	params.put(paramName, paramValue);
			log.debug("Init parameter " + paramName + ": " + paramValue);
        }
        
        if (!params.containsKey(InitParameters.FILES_TEMP_DIR)) {
            try {
    			String tempDir = ((File)servletContext.getAttribute(ServletContext.TEMPDIR)).getCanonicalPath();
    			params.put(InitParameters.FILES_TEMP_DIR, tempDir);
    			log.debug("Init parameter " + InitParameters.FILES_TEMP_DIR + ": " + tempDir);
            } catch (IOException e) {
    			e.printStackTrace();
    		}  
        }
        
        InitParameters.init(params);       
        log.info("Servlet started");
	}
	
	@Override
	public void contextDestroyed(ServletContextEvent sce) {
		log.info("Servlet context destroyed");
	}
}
