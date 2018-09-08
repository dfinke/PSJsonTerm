Add-Type -AssemblyName presentationframework

$XAML = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        WindowStartupLocation="CenterScreen"
        Title="PS JSON Terminal" Height="650" Width="1000">

    <Grid >

        <Grid.RowDefinitions>
            <RowDefinition Height="58"/>
            <RowDefinition/>
            <RowDefinition Height="155"/>
        </Grid.RowDefinitions>

        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
            <ColumnDefinition/>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>

        <GroupBox Header=" _Expression " Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="2" Margin="3">
            <TextBox x:Name="Expression" Margin="3"
                FontFamily="Consolas"
                FontSize="14"/>
        </GroupBox>

        <GroupBox Header=" _Input JSON " Grid.Row="1" Grid.Column="0" Margin="3">
            <TextBox x:Name="InputJSON" Margin="3"
                FontFamily="Consolas"
                AcceptsReturn="True"
                AcceptsTab="True"
                FontSize="14"/>
        </GroupBox>

        <GroupBox Header=" _Result " Grid.Row="1" Grid.Column="1" Margin="3">
            <TextBox x:Name="Result" Margin="3"
                FontFamily="Consolas"
                FontSize="14"/>
        </GroupBox>

        <GroupBox Header=" _PowerShell Code " Grid.Row="0" Grid.Column="2" Grid.RowSpan="3" Margin="3">
            <TextBox x:Name="PowerShellCode" Margin="3"
                FontFamily="Consolas"
                IsReadOnly="True"
                FontSize="14"/>
        </GroupBox>

        <GroupBox Header=" _Error Info " Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Margin="3">
            <TextBox x:Name="ErrorInfo" Margin="3"
                FontFamily="Consolas"
                IsReadOnly="True"
                FontSize="14"/>
        </GroupBox>

    </Grid>
</Window>
'@

# @"
# {
#     "meta": {
#         "limit": 100,
#         "offset": 0,
#         "total_count": 99
#     },
#     "objects": [
#         {
#             "caucus": null,
#             "congress_numbers": [
#                 113,
#                 114,
#                 115
#             ],
#             "current": true,
#             "description": "Junior Senator for Wisconsin",
#             "district": null,
#             "enddate": "2019-01-03",
#             "extra": {
#                 "address": "709 Hart Senate Office Building Washington DC 20510",
#                 "contact_form": "https://www.baldwin.senate.gov/feedback",
#                 "fax": "202-225-6942",
#                 "office": "709 Hart Senate Office Building",
#                 "rss_url": "http://www.baldwin.senate.gov/rss/feeds/?type=all"
#             },
#             "leadership_title": null,
#             "party": "Democrat",
#             "person": {
#                 "bioguideid": "B001230",
#                 "birthday": "1962-02-11",
#                 "cspanid": 57884,
#                 "firstname": "Tammy",
#                 "gender": "female",
#                 "gender_label": "Female",
#                 "lastname": "Baldwin",
#                 "link": "https://www.govtrack.us/congress/members/tammy_baldwin/400013",
#                 "middlename": "",
#                 "name": "Sen. Tammy Baldwin [D-WI]",
#                 "namemod": "",
#                 "nickname": "",
#                 "osid": "N00004367",
#                 "pvsid": "3470",
#                 "sortname": "Baldwin, Tammy (Sen.) [D-WI]",
#                 "twitterid": "SenatorBaldwin",
#                 "youtubeid": "witammybaldwin"
#             }
#         }
#     ]
# }
# "@

# function Eval {
#     $ResultPane.Text = ''
#     $ResultPane.Background = "White"
#     if($DataPane.Text) {
#         try {
#             $ResultPane.Text = $DataPane.Text | Invoke-Expression |Out-String
#                 #| ConvertTo-Json -Depth 15 |Out-String
#         } catch {
#             $ResultPane.Background = "Red"
#             $ResultPane.Text = $Error[0].Exception.Message
#         }
#     }
# }

$Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader ([xml]$XAML)))

# $Window.add_KeyDown({
#     param($sender, $KeyEventArgs)

#     if($KeyEventArgs.key -eq 'F5') {
#         Eval
#     }
# })

$ExpressionPane = $Window.FindName("Expression")
$InputJsonPane = $Window.FindName("InputJSON")
$ResultPane = $Window.FindName("Result")
$ErrorInfoPane = $Window.FindName("ErrorInfo")
$PowerShellCodePane = $Window.FindName("PowerShellCode")

$InputJsonPane.Text = @"
{
    "a":1,
    "c": {
        "e": [
            20,
            1,
            2,
            55,
            3,
            100
        ]
    }
}
"@

function DoEval {

    $ResultPane.Text = $null
    $ErrorInfoPane.Text = $null
    $PowerShellCodePane.Text = $null

    $Expression = $ExpressionPane.text
    if ($null -eq $Expression -or $Expression.length -eq 0) {return}

    $jsonObject = $InputJsonPane.Text | ConvertFrom-Json


    try {
        $result = "`$jsonObject.$Expression" | Invoke-Expression
        $ResultPane.Text = $result | ConvertTo-Json
        $PowerShellCodePane.Text = @"
`$jsonObject = @'
$($InputJsonPane.Text)
'@ | ConvertFrom-Json

    `$jsonObject.$($Expression)
"@
    }
    catch {
        $ErrorInfoPane.Text = $_.Exception.Message
    }
}

$ExpressionPane.add_KeyUp( {
        param($sender, $KeyEventArgs)

        DoEval
    })

$null = $ExpressionPane.Focus()

[void]$Window.ShowDialog()