/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package cipn.exporter.controller;

import cipn.exporter.util.ConfigUtil;
import cipn.exporter.util.DBUtil;
import cipn.exporter.util.FileUtil;
import cipn.exporter.util.NamedParameterStatement;
import java.io.File;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.bind.DatatypeConverter;

/**
 *
 * @author sompr
 */
public class ExportController {

    private static final Logger LOG = Logger.getLogger(ExportController.class.getName());

    private final String FILE_EXPORT = "export.sql";
    private final String EXPORT_FOLDER = "export";

    public void handleExport(List<Object> ids) {
        String hcode = ConfigUtil.getHCODE();
        String sessionNo = useSessionNo();

        String[] visitIds = ids.toArray(new String[ids.size()]);
        List<LinkedHashMap<String, String>> datasources = getDatasources(visitIds);
        if (datasources.isEmpty()) {
            return;
        }
        LOG.log(Level.INFO, "Start task for session no. \"{0}\", will export {1} files.", new Object[]{sessionNo, datasources.size()});

        String folderName = "." + File.separator + EXPORT_FOLDER + File.separator + (hcode + "CIPN" + sessionNo);
        createExportFolder(folderName);
        LOG.log(Level.INFO, "Created folder {0}", new Object[]{folderName});

        for (LinkedHashMap<String, String> ds : datasources) {
            String filename = ds.get("filename");
            String data = ds.get("xml");
            if (data == null || data.isEmpty()) {
                LOG.log(Level.INFO, "File {0} no data, skipped.", new Object[]{filename});
                continue;
            }
            try {
                createXmlFile(folderName + File.separator + filename + ".xml", data);
                LOG.log(Level.INFO, "Exported file {0}", new Object[]{filename + ".xml"});
            } catch (Exception ex) {
                Logger.getLogger(ExportController.class.getName()).log(Level.SEVERE, null, ex);
                LOG.log(Level.INFO, "Can not export file {0}, skipped.", new Object[]{filename});
            }
        }

        try {
            makeZipFile(folderName);
            LOG.log(Level.INFO, "Completed, make zip file {0}.", new Object[]{folderName + ".zip"});
            // clean up
            if (!FileUtil.deleteDirectory(new File(folderName))) {
                LOG.log(Level.INFO, "Can not remove temp directory: {0}.", new Object[]{folderName});
            }
        } catch (IOException ex) {
            Logger.getLogger(ExportController.class.getName()).log(Level.SEVERE, null, ex);
            LOG.log(Level.INFO, "Can not make zip file: {0}.", new Object[]{folderName + ".zip"});
        }
    }

    private String useSessionNo() {
        String len = ConfigUtil.getSessionNoLength();
        String sessionNo = ConfigUtil.getSessionNo();
        if (len.equals("5")) {
            ConfigUtil.updateConfig(ConfigUtil.KEY_SESSION_NO,
                    sessionNo.equals("99999")
                    ? "10000"
                    : String.valueOf(Integer.parseInt(sessionNo) + 1));
        } else {
            ConfigUtil.updateConfig(ConfigUtil.KEY_SESSION_NO,
                    sessionNo.equals("9999")
                    ? "0001"
                    : String.format("%04d", Integer.parseInt(sessionNo) + 1));
        }

        return sessionNo;
    }

    private String getQuery() throws Exception {
        String folder = ConfigUtil.getHIS().toLowerCase();
        if (folder == null || folder.isEmpty()) {
            throw new Exception("No HIS");
        }
        String query = FileUtil.readFile("." + File.separator + "sql" + File.separator + folder + File.separator + FILE_EXPORT);
        return query;
    }

    private List<LinkedHashMap<String, String>> getDatasources(String[] visitIds) {
        List<LinkedHashMap<String, String>> list = new ArrayList<>();
        try {
            String query = getQuery();
            Connection con = DBUtil.getInstance().getConnection();
            NamedParameterStatement p = new NamedParameterStatement(con, query);
            p.setArray("visitIds", con.createArrayOf("varchar", visitIds));
            LOG.log(Level.SEVERE, p.getStatement().toString());
            try (ResultSet rs = p.executeQuery()) {
                LinkedHashMap<String, String> map;
                while (rs.next()) {
                    map = new LinkedHashMap<>();
                    String key = rs.getString(1);
                    String value = rs.getString(2);
                    if (value == null) {
                        continue;
                    }
                    map.put("filename", key);
                    map.put("xml", value);
                    list.add(map);
                }
            }
            p.close();
        } catch (IOException ex) {
            Logger.getLogger(SearchController.class.getName()).log(Level.SEVERE, null, ex);
        } catch (Exception ex) {
            Logger.getLogger(SearchController.class.getName()).log(Level.SEVERE, null, ex);
        }

        return list;
    }

    private void createExportFolder(String folderName) {
        File file = new File(folderName);
        file.mkdirs();
    }

    private void createXmlFile(String filename, String data) throws Exception {
        String hash = getHash(data + "\n");

        StringBuilder xml = new StringBuilder();
        xml.append("<?xml version=\"1.0\" encoding=\"windows-874\"?>").append("\n");
        xml.append(data).append("\n");
        xml.append("<?EndNote HMAC=\"").append(hash).append("\"?>");

        FileUtil.writeFile(filename, xml.toString(), "TIS620");
    }

    private String getHash(String value) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance("MD5");
        md.update(value.getBytes());
        byte[] digest = md.digest();
        return DatatypeConverter.printHexBinary(digest).toUpperCase();
    }

    private void makeZipFile(String folderName) throws IOException {
        FileUtil.pack(folderName, folderName + ".zip");
    }
}
