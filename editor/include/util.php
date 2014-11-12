<?php

function rm_rf($file_or_dir)
{
  // TODO: do this more system-independently
  system('rm -rf ' . escapeshellarg($file_or_dir));
}
