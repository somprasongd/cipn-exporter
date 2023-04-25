/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package cipn.exporter.controller;

import cipn.exporter.util.ConfigUtil;
import java.awt.Component;
import java.util.Map;
import java.util.regex.Pattern;
import javax.swing.JOptionPane;

/**
 *
 * @author sompr
 */
public class ConfigController {

    private Pattern patternHcode = Pattern.compile("^\\d{5}$");
    private Pattern patternSessionNo4 = Pattern.compile("^\\d{4}$");
    private Pattern patternSessionNo5 = Pattern.compile("^(?!0{1})\\d{5}$");

    public void handleConfig(Component parent) {
        Map<String, String> config = ConfigUtil.readConfig();
        String his = getHISName(parent, config.get(ConfigUtil.KEY_HIS));
        String hcode = getHcode(parent, config.get(ConfigUtil.KEY_HCODE));
        if (hcode == null
                || hcode.isEmpty()
                || !patternHcode.matcher(hcode).matches()) {
            JOptionPane.showMessageDialog(parent, "รหัสสถานพยาบาลผิดรูปแบบ", "เตือน", JOptionPane.WARNING_MESSAGE);
            return;
        }

        String databaseUrl = getDatabaseUrl(parent, config.get(ConfigUtil.KEY_DB));
        if (databaseUrl == null
                || databaseUrl.isEmpty()) {
            JOptionPane.showMessageDialog(parent, "Database URL ผิดรูปแบบ", "เตือน", JOptionPane.WARNING_MESSAGE);
            return;
        }

        String sessionNoLen = getSessionNoLength(parent, config.get(ConfigUtil.KEY_SESSION_NO_LEN));
        String sessionNo = getSessionNo(parent, sessionNoLen, config.get(ConfigUtil.KEY_SESSION_NO));
        if (sessionNo == null
                || sessionNo.isEmpty()
                || !checkSessionNoFormat(sessionNoLen, sessionNo)) {
            JOptionPane.showMessageDialog(parent, "เลขงวดส่งผิดรูปแบบ", "เตือน", JOptionPane.WARNING_MESSAGE);
            return;
        }

        ConfigUtil.saveConfig(his, hcode, databaseUrl, sessionNoLen, sessionNo);
    }

    private boolean checkSessionNoFormat(String len, String value) {
        if (len == null || len.isEmpty() || len.equals("5")) {
            return patternSessionNo5.matcher(value).matches();
        }
        return patternSessionNo4.matcher(value).matches();
    }

    private String getHISName(Component parent, String defaultValue) {
        String[] hises = {"Hospital-OS", "iMed"};
        return (String) JOptionPane.showInputDialog(parent, "ชื่อระบบ", "กำหนดชื่อระบบ",
                JOptionPane.OK_CANCEL_OPTION, null, hises,
                defaultValue == null || defaultValue.isEmpty()
                ? hises[0] : defaultValue);
    }

    private String getHcode(Component parent, String defaultValue) {
        return (String) JOptionPane.showInputDialog(parent, "รหัสสถานพยาบาล (เป็นเลข 5 หลัก)", "กำหนดรหัสสถานพยาบาล",
                JOptionPane.OK_CANCEL_OPTION, null, null,
                defaultValue == null || defaultValue.isEmpty()
                ? "00000" : defaultValue);
    }

    private String getDatabaseUrl(Component parent, String defaultValue) {
        return (String) JOptionPane.showInputDialog(parent, "Database URL\njdbc:postgresql://ip:port/dbname?user=username&password=pwd",
                "กำหนดเชื่อมต่อฐานข้อมูลโรงพยาบาล", JOptionPane.OK_CANCEL_OPTION,
                null, null, defaultValue);
    }

    private String getSessionNoLength(Component parent, String defaultValue) {
        String[] hises = {"4 หลัก", "5 หลัก"};
        return (String) JOptionPane.showInputDialog(parent, "รูปแบบเลขงวด", "กำหนดรูปแบบเลขงวด",
                JOptionPane.OK_CANCEL_OPTION, null, hises,
                defaultValue == null || defaultValue.isEmpty()
                ? hises[0] : defaultValue);
    }

    private String getSessionNo(Component parent, String len, String defaultValue) {
        return (String) JOptionPane.showInputDialog(parent, "เลขงวดส่งถัดไป (เป็นเลข Running " + len + " หลัก)",
                "กำหนดเลขงวดส่ง", JOptionPane.OK_CANCEL_OPTION,
                null, null, defaultValue == null || defaultValue.isEmpty()
                ? (len.equals("4") ? "0001" : "10000") : defaultValue);
    }

}
