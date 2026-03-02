// Phase 4: Voice Service (STT + TTS)
// TODO: Implement speech-to-text via Swift helper and text-to-speech via macOS `say`
// - Compile helpers/stt.swift with swiftc
// - listen(): spawn Swift STT subprocess, stream transcription
// - speak(): spawn `say` command with response text
// - Voice loop: listen -> transcribe -> agent -> speak -> repeat

export class VoiceService {
  async speak(text: string): Promise<void> {
    // TODO: Use macOS `say` command
    console.log(`[TTS] Would speak: ${text}`);
  }

  async listen(): Promise<string> {
    // TODO: Use Swift STT helper
    throw new Error('Voice service not implemented yet (Phase 4)');
  }

  async isAvailable(): Promise<boolean> {
    // TODO: Check if STT helper is compiled and microphone is available
    return false;
  }
}

export const voiceService = new VoiceService();
