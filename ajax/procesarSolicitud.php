<?php
	session_start();
	require("../funciones/php/connection.php");

	//print('<pre>' . print_r($_SESSION,true) . '</pre>');
	//print('<pre>' . print_r($_POST,true) . '</pre>');

	$supervisor = $_SESSION['user'];
	$reserva = $_POST['idReserva'];
	$decision = $_POST['decision'];
	
	$string = "CALL pr_ProcesarSolicitud($reserva,'$supervisor',$decision,@salida)";
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