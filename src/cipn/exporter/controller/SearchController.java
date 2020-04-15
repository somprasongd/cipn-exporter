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
import com.hosos.comp.table.obj.TableComplexDataSource;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author sompr
 */
public class SearchController {

    private final String FILE_SEARCH = "search.sql";
    private final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

    public List<TableComplexDataSource> handleSearch(String hn, String firstname, String lastname,
            Date startDate, Date endDate) throws Exception {
        List<TableComplexDataSource> list = new ArrayList<>();
        try {
            String query = getQuery();
            Connection con = DBUtil.getInstance().getConnection();
            NamedParameterStatement p = new NamedParameterStatement(con, query);
            p.setString("hn", hn + "%");
            p.setString("firstname", firstname + "%");
            p.setString("lastname", lastname + "%");
            p.setString("startDate", sdf.format(startDate));
            p.setString("endDate", sdf.format(endDate));
            try (ResultSet rs = p.executeQuery()) {
                TableComplexDataSource dataSource;
                while (rs.next()) {
                    dataSource = new TableComplexDataSource();
                    dataSource.setId(rs.getString("t_visit_id"));
                    dataSource.setValues(new Object[]{
                        rs.getString("hn"),
                        rs.getString("pname"),
                        rs.getString("invno"),
                        rs.getString("amount"),
                        rs.getString("visit_begin_visit_time")
                    });
                    list.add(dataSource);
                }
            }
            p.close();
        } catch (IOException ex) {
            Logger.getLogger(SearchController.class.getName()).log(Level.SEVERE, null, ex);
        } catch (Exception ex) {
            Logger.getLogger(SearchController.class.getName()).log(Level.SEVERE, null, ex);
            if (ex.getMessage().equals("No HIS")
                    || ex.getMessage().equals("No database config.")) {
                throw ex;
            }
        }
        return list;
    }

    private String getQuery() throws Exception {
        String folder = ConfigUtil.getHIS().toLowerCase();
        if (folder == null || folder.isEmpty()) {
            throw new Exception("No HIS");
        }

        String query = FileUtil.readFile("." + File.separator + "sql" + File.separator + folder + File.separator + FILE_SEARCH);
        return query;
    }
}
