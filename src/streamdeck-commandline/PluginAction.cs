using System.Diagnostics;
using System.Threading.Tasks;
using BarRaider.SdTools;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace StreamDeckCommandLine
{
    [PluginActionId("com.springhillsoftware.commandline")]
    public class PluginAction : PluginBase
    {
        private readonly PluginSettings _settings;

        public PluginAction(ISDConnection connection, InitialPayload payload) : base(connection, payload)
        {
            if (payload.Settings == null || payload.Settings.Count == 0)
            {
                _settings = new PluginSettings();
                SaveSettingsAsync();
            }
            else
            {
                _settings = payload.Settings.ToObject<PluginSettings>();
            }
        }

        public override void Dispose()
        {
            Logger.Instance.LogMessage(TracingLevel.INFO, "Destructor called");
        }

        public override async void KeyPressed(KeyPayload payload)
        {
            Logger.Instance.LogMessage(TracingLevel.INFO, "Key Pressed");
            await ExecuteCommandLine();
        }

        public override void KeyReleased(KeyPayload payload) { }

        public override void OnTick() { }

        public override void ReceivedSettings(ReceivedSettingsPayload payload)
        {
            Tools.AutoPopulateSettings(_settings, payload.Settings);
            SaveSettingsAsync();
        }

        public override void ReceivedGlobalSettings(ReceivedGlobalSettingsPayload payload) { }

        private async void SaveSettingsAsync()
        {
            await Connection.SetSettingsAsync(JObject.FromObject(_settings));
        }

        private async Task ExecuteCommandLine()
        {
            var cmd = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "cmd.exe",
                    RedirectStandardInput = true,
                    RedirectStandardOutput = true,
                    CreateNoWindow = true,
                    UseShellExecute = false
                }
            };

            cmd.Start();
            await cmd.StandardInput.WriteLineAsync(_settings.CommandLine);
            await cmd.StandardInput.FlushAsync();
            cmd.StandardInput.Close();
            await Task.Run(() => cmd.WaitForExit());
        } 

        private class PluginSettings
        {
            [JsonProperty(PropertyName = "commandLine")]
            public string CommandLine { get; set; } = "";
        }
    }
}
