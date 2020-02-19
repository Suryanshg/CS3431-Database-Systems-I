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


public class Reporting {

    public static void main(String[] argv) throws SQLException {

        try {
		Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return;
        }


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

        } else {
            System.out.println("Failed to make connection!");
        }
        connection.close();
    }

}
