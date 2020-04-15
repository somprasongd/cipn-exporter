/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package cipn.exporter.playground;

import java.io.File;
import java.io.StringWriter;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;

/**
 *
 * @author sompr
 */
public class MakeXML {

    public static void main(String[] args) {
        //Java object. We will convert it to XML.
        Employee employee = new Employee(1, "Lokesh", "Gupta", new Department(101, "IT"));

        //Method which uses JAXB to convert object to XML
        jaxbObjectToXML(employee);
    }

    private static void jaxbObjectToXML(Employee employee) {
        try {
            //Create JAXB Context
            JAXBContext jaxbContext = JAXBContext.newInstance(Employee.class);

            //Create Marshaller
            Marshaller jaxbMarshaller = jaxbContext.createMarshaller();

            //Required formatting??
            jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);

//            jaxbMarshaller.setProperty("com.sun.xml.internal.bind.xmlHeaders",
//                    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
//            jaxbMarshaller.setProperty("com.sun.xml.internal.bind.xmlDeclaration", Boolean.FALSE);
////            jaxbMarshaller.setProperty(Marshaller.JAXB_FRAGMENT, Boolean.TRUE);
            // Change encode from utf-8 to windows-874
            jaxbMarshaller.setProperty(Marshaller.JAXB_ENCODING, "windows-874");
            jaxbMarshaller.setProperty(Marshaller.JAXB_SCHEMA_LOCATION, "asd");

//            jaxbMarshaller.setProperty("com.sun.xml.internal.bind.xmlDeclaration", Boolean.FALSE);
            jaxbMarshaller.setProperty("com.sun.xml.internal.bind.xmlHeaders", "<?xml version=\"1.0\" encoding=\"windows-874\"?>\n");
            //Print XML String to Console
            StringWriter sw = new StringWriter();
            sw.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
            //Write XML to StringWriter
            jaxbMarshaller.marshal(employee, sw);

            //Verify XML Content
            String xmlContent = sw.toString();
            System.out.println(xmlContent);

        } catch (JAXBException e) {
            e.printStackTrace();
        }
    }

    private static void jaxbObjectToXMLFile(Employee employee) {
        try {
            //Create JAXB Context
            JAXBContext jaxbContext = JAXBContext.newInstance(Employee.class);

            //Create Marshaller
            Marshaller jaxbMarshaller = jaxbContext.createMarshaller();

            //Required formatting??
            jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);

            //Store XML to File
            File file = new File("employee.xml");

            //Writes XML file to file-system
            jaxbMarshaller.marshal(employee, file);
        } catch (JAXBException e) {
            e.printStackTrace();
        }
    }
}
