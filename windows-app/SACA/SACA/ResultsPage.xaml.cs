using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;

namespace SACA
{
    public sealed partial class ResultsPage : Page
    {
        public ResultsPage()
        {
            this.InitializeComponent();
        }

        private void Done_Click(object sender, RoutedEventArgs e)
        {
            // Take the user back to the Dashboard after they finish
            this.Frame.Navigate(typeof(DashboardPage));
        }
    }
}