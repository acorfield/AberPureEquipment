package uk.ac.aber.pure.transform;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.DirectoryNotEmptyException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.FileTime;
import java.util.Date;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;

import org.apache.log4j.Logger;

import uk.ac.aber.pure.jersey.InitParameters;

public class FileHandler {
	public static final int BUFFER_SIZE = 4096;
    public static final String CHARSET = "UTF-8"; 
    public static final String TEMP_FILES_CREATION_TIME = "creationTime";

    private static final Logger log = Logger.getLogger(FileHandler.class);
	
	public Path getNewTempDir(String prefix) throws IOException {	
		Path tempDir = Files.createTempDirectory(Paths.get(InitParameters.getString(InitParameters.FILES_TEMPDIR)), prefix);
		tempDir.toFile().deleteOnExit();
		log.debug("Created temp directory " + tempDir.toString());
		return tempDir;
	}
	
	public Path getTempDir(String prefix) throws IOException {
		DirectoryStream<Path> dirStream = Files.newDirectoryStream(Paths.get(InitParameters.getString(InitParameters.FILES_TEMPDIR)));
		TreeMap<Long,Path> tempDirs = new TreeMap<Long, Path>();
		for (Path path : dirStream) {
			if (path.getFileName().toString().startsWith(prefix)) {			
				log.debug("Found temp directory " + path.getFileName().toString());
				long creationTime = ((FileTime)Files.getAttribute(path, TEMP_FILES_CREATION_TIME)).toMillis();
				tempDirs.put(creationTime, path);
			}
		}
		return purgeDirectories(tempDirs);
	}
	
	public Path getTempFile(Path tempDir, String prefix, String suffix) throws IOException {
		DirectoryStream<Path> dirStream = Files.newDirectoryStream(tempDir);
		for (Path path : dirStream) {
			if (path.getFileName().toString().startsWith(prefix) && path.getFileName().toString().endsWith(suffix)) {
				log.debug("Found temp file " + path.getFileName().toString());
				return path;
			}
		}
		return null;
	}
	
	private Path purgeDirectories(TreeMap<Long,Path> tempDirs) throws IOException {		
		if (tempDirs.size() == 0)
			return null;	

		//Remove most recent directory 
		Map.Entry<Long,Path> mostRecent = tempDirs.pollLastEntry();
		//Don't purge directories, just return most recent if negative value for timeToLive
		if (InitParameters.getLong(InitParameters.FILES_TIMETOLIVE) < 0)
			return mostRecent.getValue();

		//Delete remaining older directories
		log.debug("purging old temp directorie(s) " + tempDirs.size());
		Iterator<Path> it = tempDirs.values().iterator();	
		while (it.hasNext()) {
			delete(it.next());
		}
		//TODO Delete only if Pure service is up
		//Delete most recent if creation time past time to live
		if (mostRecent.getKey() < System.currentTimeMillis() - InitParameters.getLong(InitParameters.FILES_TIMETOLIVE)) {
			log.debug("purging temp directory created " + new Date(mostRecent.getKey()));
			delete(mostRecent.getValue());
			return null;
		} else {
			return mostRecent.getValue();			
		}		
	}

	public Path getNewTempFile(Path tempDir, String prefix, String suffix) throws IOException {
		Path tempFile = Files.createTempFile(tempDir, prefix, suffix);
		tempFile.toFile().deleteOnExit();
		log.debug("Created temp file " + tempFile.toString());
		return tempFile;
	}
	
	//recursive delete
	private void delete(Path path) throws IOException {		
		if (Files.isDirectory(path)) {
			DirectoryStream<Path> dirStream = Files.newDirectoryStream(path);
			for (Path p : dirStream) {
				delete(p);				
			}
			dirStream.close();
		}
		
		try {
			Files.delete(path);
			log.debug("Deleted temp file " + path.toString());
		} catch (DirectoryNotEmptyException e) {
			//Don't delete if directory still contains files e.g. keepXml or keepHtml 
		}	
	}
	
	public void writeToFile(InputStream in, Path tempFile) throws IOException {
		OutputStream out = getOutputStream(tempFile);
		
		byte[] bytes = new byte[BUFFER_SIZE];
		int len = 0;
		while ((len = in.read(bytes)) != -1) {
			out.write(bytes, 0, len);
		}
		in.close();
		out.flush();
		out.close();
	}
	
	public OutputStream getOutputStream(Path tempFile) throws IOException {
		return Files.newOutputStream(tempFile);
	}
	
	public OutputStream getOutputStream() throws IOException {
		return new ByteArrayOutputStream();
	}

	public InputStream getUrlInputStream(String urlString) throws IOException, URISyntaxException {
		URL url = new URI(urlString).toURL();
		return url.openStream();
	}
}