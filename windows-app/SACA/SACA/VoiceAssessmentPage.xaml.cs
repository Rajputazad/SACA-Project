using System;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Windows.Media.SpeechRecognition;

namespace SACA
{
    public sealed partial class VoiceAssessmentPage : Page
    {
        private SpeechRecognizer _speechRecognizer;
        private bool _isListening = false;

        public VoiceAssessmentPage()
        {
            this.InitializeComponent();
            InitializeRecognizer();
        }

        private async void InitializeRecognizer()
        {
            try
            {
                _speechRecognizer = new SpeechRecognizer();

                // Add dictation constraint
                var dictationConstraint = new SpeechRecognitionTopicConstraint(SpeechRecognitionScenario.Dictation, "dictation");
                _speechRecognizer.Constraints.Add(dictationConstraint);

                await _speechRecognizer.CompileConstraintsAsync();

                // Continuous recognition event
                _speechRecognizer.ContinuousRecognitionSession.ResultGenerated += (s, args) =>
                {
                    DispatcherQueue.TryEnqueue(() =>
                    {
                        if (!string.IsNullOrEmpty(args.Result.Text))
                        {
                            SpeechToTextBox.Text += args.Result.Text + " ";
                        }
                    });
                };
            }
            catch (Exception ex)
            {
                // Check for the specific "Privacy Policy" error code
                if ((uint)ex.HResult == 0x80045509)
                {
                    DispatcherQueue.TryEnqueue(() =>
                    {
                        StatusText.Text = "Privacy Error: Please enable 'Online Speech Recognition' in Windows Settings.";
                        SpeechToTextBox.PlaceholderText = "Speech is disabled by Windows Privacy Settings.";
                    });
                }
                else
                {
                    StatusText.Text = "Error: " + ex.Message;
                }
            }

        }

        private async void RecordButton_Click(object sender, RoutedEventArgs e)
        {
            if (!_isListening)
            {
                try
                {
                    await _speechRecognizer.ContinuousRecognitionSession.StartAsync();
                    _isListening = true;
                    RecordButton.Content = "Stop Listening";
                    StatusText.Text = "Listening...";
                    SpeechToTextBox.Text = ""; // Clear for new recording
                }
                catch (Exception ex)
                {
                    StatusText.Text = "Error: " + ex.Message;
                }
            }
            else
            {
                await _speechRecognizer.ContinuousRecognitionSession.StopAsync();
                _isListening = false;
                RecordButton.Content = "Start Over";
                StatusText.Text = "Finished listening.";
                SubmitButton.IsEnabled = true;
            }
        }

        private void Submit_Click(object sender, RoutedEventArgs e)
        {
            // Move to results, passing the text from our text box
            this.Frame.Navigate(typeof(ResultsPage), SpeechToTextBox.Text);
        }
    }
}