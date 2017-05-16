package uk.ac.aber.pure.jersey;

import java.util.HashMap;

public class InitParameters {
	public static final String FILES_TEMP_DIR = "files.tempdir";
	public static final String FILES_TIME_TO_LIVE = "files.timetolive";
	public static final String FILES_KEEP_XML = "files.keepxml";
	
	public static final String STYLESHEET_EQUIPMENT_XML = "stylesheet.equipment.xml";
	public static final String STYLESHEET_EQUIPMENT_HTML = "stylesheet.equipment.html";
	public static final String STYLESHEET_COUNT_XML = "stylesheet.count.xml";
	
	public static final String PURE_SERVICE_RENDER_PARAM = "pure.service.render.param";
	public static final String PURE_SERVICE_WINDOW_SIZE_PARAM = "pure.service.window.size.param";
	public static final String PURE_SERVICE_WINDOW_OFFSET_PARAM = "pure.service.window.offset.param";
	
	public static final String PURE_SERVICE_RENDER_VALUE = "pure.service.render.value";
	public static final String PURE_SERVICE_WINDOW_SIZE_VALUE = "pure.service.window.size.value";
	

	public static final String PURE_SERVICE_URL = "pure.service.url";
	public static final String PURE_RESOURCE_EQUIPMENT = "pure.resource.equipment";

	private static HashMap<String, String> initParameters;
	
	public static void init(HashMap<String, String> params) {
		InitParameters.initParameters = params;
	}

	public static Boolean getBoolean(String key) {
		return new Boolean(initParameters.get(key));
	}
	
	public static String getString(String key) {
		return initParameters.get(key);
	}

	public static Integer getInteger(String key) {
		try {
			return Integer.parseInt(initParameters.get(key));
		} catch (NumberFormatException e) {
			return null;
		}
	}
	
	public static Long getLong(String key) {
		try {
			return Long.parseLong(initParameters.get(key));
		} catch (NumberFormatException e) {
			return null;
		}
	}	
}