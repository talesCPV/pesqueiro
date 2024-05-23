<?php

    if(IsSet($_FILES["data"])){
       
        $file = $_FILES["data"]["tmp_name"];
var_dump($file);
        $filename = $_POST["filename"]=="" ? $_FILES["data"]["name"] : $_POST["filename"];
        $path = getcwd().'/../tmp/';
    
        if (!is_dir($path)){
          mkdir($path, 0777, true);
        }
    
        $url = $path.'teste.pdf';   
        if (file_exists($file)){             
          if(move_uploaded_file($file, $url)){      
            $out = $filename;
          }
        }

    } else {
        echo "No Data Sent";
    }

?>