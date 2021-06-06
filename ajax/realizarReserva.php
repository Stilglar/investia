<?php
	session_start();
	require("../funciones/php/connection.php");

	//print('<pre>' . print_r($_SESSION,true) . '</pre>');
	//print('<pre>' . print_r($_POST,true) . '</pre>');

	$user = $_SESSION['user'];
	$equipo = $_POST['equipo'];
	$fechaInicio = $_POST['fechaInicio'];
	$fechaFin = $_POST['fechaFin'];
	$horaInicio = $_POST['horaInicio'];
	$horaFin = $_POST['horaFin'];
	
	$string = "CALL pr_RealizarReserva('$user',$equipo,'$fechaInicio','$fechaFin','$horaInicio','$horaFin',@salida)";
	$resultado = mysqli_query($con,$string)
		or die('{"error":"Se ha producido un error"}');
	
	$string = 'SELECT @salida';
	$resultado = mysqli_query($con,$string)
		or die('{"error":"Se ha producido un error"}');

	if(mysqli_num_rows($resultado) != 0){
		$fila = mysqli_fetch_assoc($resultado);
		$retorno = array();
		$retorno['salida'] = $fila['@salida'];
		echo(json_encode($retorno));
	}
	else{
		echo '{"error":"Se ha producido un error"}';
	}

	// Liberar resultados
	mysqli_free_result($resultado);
	// Cerrar la conexión
	mysqli_close($con);
?>