<?php
	require("../funciones/php/connection.php");
	$string = 'CALL pr_Equipos()';
	$resultado = mysqli_query($con,$string)
		or die("Ocurrio un error en la consulta SQL");
	if(mysqli_num_rows($resultado) != 0){
		$datos = array();
		while($fila = mysqli_fetch_assoc($resultado)){
			$datos[$fila['idEquipo']] = $fila['nombre'] . '|' . $fila['tipo'];
		}
		echo(json_encode($datos));
        //print('<pre>' . print_r($datos,true) . '</pre>');
	}
	else{
		echo '{"error":"Se ha producido un error"}';
	}

	// Liberar resultados
	mysqli_free_result($resultado);
	// Cerrar la conexión
	mysqli_close($con);
?>