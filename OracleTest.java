import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.SQLException;


/* ++++++++++++++++++++++++++++++++++++++++++++++
  Make sure you did the following before execution
     1) Log in to CCC machine using your WPI account

     2) Set environment variables using the following command
       > source /cs/bin/oracle-setup

     3- Set CLASSPATH for java using the following command
       > export CLASSPATH=./:/usr/lib/oracle/18.5/client64/lib/ojdbc8.jar

     4- Write your java code (say file name is OracleTest.java) and then compile it using the  following command
       > /usr/local/bin/javac OracleTest.java

     5- Run it
        > /usr/local/bin/java OracleTest
  ++++++++++++++++++++++++++++++++++++++++++++++  */


public class OracleTest {

    public static void main(String[] argv) throws SQLException{


	
        System.out.println("-------- Oracle JDBC Connection Testing ------");
        System.out.println("-------- Step 1: Registering Oracle Driver ------");
        try {
		Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            System.out.println("Where is your Oracle JDBC Driver? Did you follow the execution steps. ");
            System.out.println("");
            System.out.println("*****Open the file and read the comments in the beginning of the file****");
            System.out.println("");
            e.printStackTrace();
            return;
        }

        System.out.println("Oracle JDBC Driver Registered Successfully !");


	System.out.println("-------- Step 2: Building a Connection ------");
        Connection connection = null;
        try {
            connection = DriverManager.getConnection(
                                                     "jdbc:oracle:thin:@csorcl.cs.wpi.edu:1521:orcl", argv[0],
                                                     argv[1]);

        } catch (SQLException e) {
            System.out.println("Connection Failed! Check output console");
            e.printStackTrace();
            return;
        }

        if (connection != null) {
            System.out.println("You made it. Connection is successful. Take control of your database now!");
        } else {
            System.out.println("Failed to make connection!");
        }
        connection.close();
    }

}
