<?php   

  $out = [];

	if (IsSet($_POST["path"])){
	  $path = getcwd().$_POST["path"];
      if (file_exists($path)) {
          $fp = fopen($path, "r");
          $resp = "";
          while (!feof ($fp)) {
              $resp = $resp . fgets($fp,4096);
          }
          fclose($fp);
          $out = json_decode($resp);
      }else{
          $fp = fopen($path, "a");
          fwrite($fp,json_encode($out));
          fclose($fp);          
      }            

  }
        
//    var_dump($out);
	print json_encode($out);

?>