{...}: {
  # Local LLM runtime. Imported only by hosts that should run models locally.
  # Expand this module as the local-LLM setup grows.
  services.ollama.enable = true;
}
