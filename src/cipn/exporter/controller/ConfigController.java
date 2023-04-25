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
    private Pattern patternSessionNo = Pattern.compile("^(?!0{1})\\d{4,5}$");

    public void handleConfig(Component parent) {
        Map<String, String> config = ConfigUtil.readConfig();
        String his = getHISName(parent, config.get(ConfigUtil.KEY_HIS));
        String hcode = getHcode(parent, config.get(ConfigUtil.KEY_HCODE));
        String databaseUrl = getDatabaseUrl(parent, config.get(ConfigUtil.KEY_DB));
        String sessionNo = getSessionNo(parent, config.get(ConfigUtil.KEY_SESSION_NO));

        if (hcode == null
                || hcode.isEmpty()
                || !patternHcode.matcher(hcode).matches()) {
            JOptionPane.showMessageDialog(parent, "รหัสสถานพยาบาลผิดรูปแบบ", "เตือน", JOptionPane.WARNING_MESSAGE);
            return;
        }

        if (sessionNo == null
                || sessionNo.isEmpty()
                || !patternSessionNo.matcher(sessionNo).matches()) {
            JOptionPane.showMessageDialog(parent, "เลขงวดส่งผิดรูปแบบ", "เตือน", JOptionPane.WARNING_MESSAGE);
            return;
        }

        ConfigUtil.saveConfig(his, hcode, databaseUrl, sessionNo);
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

    private String getSessionNo(Component parent, String defaultValue) {
        return (String) JOptionPane.showInputDialog(parent, "เลขงวดส่งถัดไป (เป็นเลข Running 4 หรือ 5 หลัก)",
                "กำหนดเลขงวดส่ง", JOptionPane.OK_CANCEL_OPTION,
                null, null, defaultValue == null || defaultValue.isEmpty()
                ? "10000" : defaultValue);
    }
}
