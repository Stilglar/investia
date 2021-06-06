<?php
	require("../funciones/php/connection.php");
	
	$string = "CALL pr_ConsultarSolicitudes()";
	$resultado = mysqli_query($con,$string)
		or die("Ocurrió un error en la consulta SQL");
	if(mysqli_num_rows($resultado) != 0){
		$datos = array();
		while($fila = mysqli_fetch_assoc($resultado)){
			$datos[$fila['idPrestamo']] = $fila['usuario'] . '|' . $fila['nombre'] . '|' . $fila['inicio'] . '|' . $fila['final'];
		}
		echo(json_encode($datos));
		//print('<pre>' . print_r($datos,true) . '</pre>');
	}
	else{
		echo '{"vacio":"No hay solicitudes pendientes de ser procesadas"}';
	}

	// Liberar resultados
	mysqli_free_result($resultado);
	// Cerrar la conexión
	mysqli_close($con);
?>