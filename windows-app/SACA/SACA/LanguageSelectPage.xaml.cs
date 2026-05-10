using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Controls.Primitives;
using Microsoft.UI.Xaml.Data;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Navigation;

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace SACA;

/// <summary>
/// An empty page that can be used on its own or navigated to within a Frame.
/// </summary>
public sealed partial class LanguageSelectPage : Page
{
    public LanguageSelectPage()
    {
        InitializeComponent();
    }
    private void Language_Selected(object sender, RoutedEventArgs e)
    {
        // This tells the Frame to swap the current Splash page 
        // for the Dashboard page shown in the PDF
        if (this.Frame != null)
        {
            this.Frame.Navigate(typeof(VoiceAssessmentPage));
        }
    }
}
