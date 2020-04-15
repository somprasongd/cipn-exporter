/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package cipn.exporter.util;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author sompr
 */
public class ConfigUtil {

    public static final String CONFIG_FILE = ".env";
    public static final String KEY_HIS = "HIS";
    public static final String KEY_HCODE = "HCODE";
    public static final String KEY_DB = "DB_URL";
    public static final String KEY_SESSION_NO = "SESSION_NO";

    private static String encode(String text) throws UnsupportedEncodingException {
        String base64encodedString = Base64.getEncoder().encodeToString(
                text.getBytes("utf-8"));
        return base64encodedString;
    }

    private static String decode(String base64encodedString) throws UnsupportedEncodingException {
        byte[] base64decodedBytes = Base64.getDecoder().decode(base64encodedString);
        return new String(base64decodedBytes, "utf-8");
    }

    public static String get(String key) {
        Map<String, String> config = readConfig();
        return config.get(key);
    }

    public static String getHIS() {
        return get(KEY_HIS);
    }

    public static String getHCODE() {
        return get(KEY_HCODE);
    }

    public static String getDBUrl() {
        return get(KEY_DB);
    }

    public static String getSessionNo() {
        return get(KEY_SESSION_NO);
    }

    public static Map<String, String> readConfig() {
        Map<String, String> config = new HashMap<>();
        try {
            List<String> lines = FileUtil.readFileInList(CONFIG_FILE);
            for (String line : lines) {
                String keyValue = decode(line);
                int index = keyValue.indexOf("=");
                String key = keyValue.substring(0, index);
                String value = keyValue.substring(index + 1);
                config.put(key, value);
            }
        } catch (IOException ex) {
            Logger.getLogger(ConfigUtil.class.getName()).log(Level.SEVERE, null, ex);
        }
        return config;
    }

    public static boolean writeConfig(String text) {
        try {
            String[] lines = text.split("\n");
            String encoded = "";
            for (int i = 0; i < lines.length; i++) {
                String line = lines[i];
                encoded += "\n" + encode(line);
            }
            FileUtil.writeFile(CONFIG_FILE, encoded.substring(1));
            return true;
        } catch (IOException ex) {
            Logger.getLogger(ConfigUtil.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
    }

    public static void updateConfig(String key, String value) {
        Map<String, String> config = ConfigUtil.readConfig();
        config.put(key, value);
        String his = config.get(ConfigUtil.KEY_HIS);
        String hcode = config.get(ConfigUtil.KEY_HCODE);
        String databaseUrl = config.get(ConfigUtil.KEY_DB);
        String sessionNo = config.get(ConfigUtil.KEY_SESSION_NO);

        saveConfig(his, hcode, databaseUrl, sessionNo);
    }

    public static void saveConfig(String his, String hcode, String databaseUrl, String sessionNo) {
        StringBuilder str = new StringBuilder();
        str.append(ConfigUtil.KEY_HIS).append("=").append(his == null ? "" : his);
        str.append("\n");
        str.append(ConfigUtil.KEY_HCODE).append("=").append(hcode == null ? "" : hcode);
        str.append("\n");
        str.append(ConfigUtil.KEY_DB).append("=").append(databaseUrl == null ? "" : databaseUrl);
        str.append("\n");
        str.append(ConfigUtil.KEY_SESSION_NO).append("=").append(sessionNo == null ? "" : sessionNo);
        ConfigUtil.writeConfig(str.toString());
    }

    public static boolean isValide() {
        Map<String, String> config = ConfigUtil.readConfig();
        return config.containsKey(ConfigUtil.KEY_HIS)
                && config.containsKey(ConfigUtil.KEY_HCODE)
                && config.containsKey(ConfigUtil.KEY_DB)
                && config.containsKey(ConfigUtil.KEY_SESSION_NO);
    }
}
