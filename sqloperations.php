<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "ag12";
$table = "alumnos";


// Crear conexión
$conn = new mysqli($servername, $username, $password, $dbname);


// Verificar conexión
if ($conn->connect_error) {
    die("Connection Failed: " . $conn->connect_error);
    return;
}


// Leer los datos JSON enviados desde la app
$data = json_decode(file_get_contents("php://input"), true);
error_log(print_r($data, true)); // Esto imprimirá los datos en el archivo de log de PHP


// Acción recibida desde la app
$action = $data["action"];


// Acción de insertar datos
if ("INSERT_DATA" == $action) {
    // Verificar si los datos son válidos
    if (isset($data['nombre']) && isset($data['apellido_paterno']) && isset($data['apellido_materno']) && isset($data['telefono']) && isset($data['correo'])) {
        $nombre = $data['nombre'];
        $apellido_pat = $data['apellido_paterno'];
        $apellido_mat = $data['apellido_materno'];
        $tel = $data['telefono'];
        $mail = $data['correo'];
       
        // Escapar valores para evitar inyecciones SQL
        $nombre = $conn->real_escape_string($nombre);
        $apellido_pat = $conn->real_escape_string($apellido_pat);
        $apellido_mat = $conn->real_escape_string($apellido_mat);
        $tel = $conn->real_escape_string($tel);
        $mail = $conn->real_escape_string($mail);


        // Consulta para insertar los datos
        $sql = "INSERT INTO $table (NOMBRE, APELLIDO_PAT, APELLIDO_MAT, TEL, MAIL)
                VALUES ('$nombre', '$apellido_pat', '$apellido_mat', '$tel', '$mail')";
       
        if ($conn->query($sql) === TRUE) {
            echo json_encode(["status" => "success"]);
        } else {
            error_log("SQL Error: " . $conn->error); // Esto registrará el error SQL si ocurre
            echo json_encode(["status" => "error", "message" => $conn->error]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Faltan datos"]);
    }
}


// Acción de búsqueda
if ("SEARCH_DATA" == $action) {
    // Obtener el término de búsqueda
    $searchTerm = isset($data['searchTerm']) ? $data['searchTerm'] : '';


    // Escapar el término de búsqueda para evitar inyecciones SQL
    $searchTerm = $conn->real_escape_string($searchTerm);


    // Consulta de búsqueda con LIKE
    $sql = "SELECT * FROM $table WHERE NOMBRE LIKE '%$searchTerm%' OR APELLIDO_PAT LIKE '%$searchTerm%' OR APELLIDO_MAT LIKE '%$searchTerm%'";


    $result = $conn->query($sql);
    $data = [];


    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
    }


    echo json_encode($data); // Retorna los datos encontrados
}


// Acción de actualización
if ("UPDATE_DATA" == $action) {
    // Verificar si los datos son válidos
    if (isset($data['id']) && isset($data['nombre']) && isset($data['apellido_paterno']) && isset($data['apellido_materno']) && isset($data['telefono']) && isset($data['correo'])) {
        $id = $data['id'];
        $nombre = $data['nombre'];
        $apellido_pat = $data['apellido_paterno'];
        $apellido_mat = $data['apellido_materno'];
        $tel = $data['telefono'];
        $mail = $data['correo'];


        // Escapar valores para evitar inyecciones SQL
        $id = $conn->real_escape_string($id);
        $nombre = $conn->real_escape_string($nombre);
        $apellido_pat = $conn->real_escape_string($apellido_pat);
        $apellido_mat = $conn->real_escape_string($apellido_mat);
        $tel = $conn->real_escape_string($tel);
        $mail = $conn->real_escape_string($mail);


        // Consulta para actualizar los datos
        $sql = "UPDATE $table SET NOMBRE='$nombre', APELLIDO_PAT='$apellido_pat', APELLIDO_MAT='$apellido_mat', TEL='$tel', MAIL='$mail' WHERE ID=$id";


        if ($conn->query($sql) === TRUE) {
            echo json_encode(["status" => "success"]);
        } else {
            error_log("SQL Error: " . $conn->error); // Esto registrará el error SQL si ocurre
            echo json_encode(["status" => "error", "message" => $conn->error]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Faltan datos"]);
    }
}


// Acción de eliminación
if ("DELETE_DATA" == $action) {
    // Verificar si el ID está presente
    if (isset($data['id'])) {
        $id = $data['id'];


        // Escapar el ID para evitar inyecciones SQL
        $id = $conn->real_escape_string($id);


        // Consulta para eliminar el registro
        $sql = "DELETE FROM $table WHERE ID=$id";


        if ($conn->query($sql) === TRUE) {
            echo json_encode(["status" => "success"]);
        } else {
            error_log("SQL Error: " . $conn->error); // Esto registrará el error SQL si ocurre
            echo json_encode(["status" => "error", "message" => $conn->error]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Falta el ID para eliminar"]);
    }
}


// Acción de obtener todos los registros
if ("GET_ALL_DATA" == $action) {
    // Consulta para obtener todos los registros
    $sql = "SELECT * FROM $table";
    $result = $conn->query($sql);
    $data = [];


    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
    }


    echo json_encode($data); // Retorna todos los registros
}


$conn->close();
return;
?>
