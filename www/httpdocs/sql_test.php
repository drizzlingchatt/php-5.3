<?php
$servername = "mysql";
$username = "channel";
$password = "chen1qaz2wsx";
// $username = "root";
// $password = "yWuSRG6an436";

// Create connection
$conn_sql = new mysqli($servername, $username, $password);
$db_list = $conn_sql ? $conn_sql->query("SHOW DATABASES") : null;
$conn = new mysqli($servername, $username, $password, "channel");

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully: <br>";

// Show tables in the database
$result = $conn->query("SHOW TABLES");
if ($result && $result->num_rows > 0) {
    echo "<br>Tables in database 'channel':<br>";
    while ($row = $result->fetch_array()) {
        echo $row[0] . "<br>";
    }
} else {
    echo "<br>No tables found.";
}


// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully";
if ($db_list) {
    echo "<br>Databases:<br>";
    while ($row = mysqli_fetch_array($db_list)) {
        echo $row[0] . "<br>";
    }
} else {
    echo "No databases found.";
}
$conn->close();
