'use strict';

function resetGPUs() {
  // set the number of GPUs to 0 when changing to the "automatic" partition
  const $queue = $('#batch_connect_session_context_auto_queues');
  const $gpus  = $('#batch_connect_session_context_dynamic_num_gpu_slots');

  if ($queue.val() === "") {
    $gpus.val("0").trigger('change');
  }
}

$(document).on('change', '#batch_connect_session_context_auto_queues', resetGPUs);
