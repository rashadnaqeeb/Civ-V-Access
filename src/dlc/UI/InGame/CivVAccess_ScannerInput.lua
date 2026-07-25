-- Scanner search text entry, pushed on top of ScannerHandler when the
-- user presses Ctrl+F. EditCapture over the dedicated off-screen
-- WorldView EditBox (CivVAccessScannerSearchEntry), so typed queries
-- follow the player's keyboard layout; the screen reader provides typing
-- echo. Enter commits the query and speaks the result (an empty commit
-- speaks the no-match reply, as it always has), Escape cancels.

ScannerInput = {}

function ScannerInput.open()
    EditCapture.open({
        name = "ScannerInput",
        control = Controls.CivVAccessScannerSearchEntry,
        onCommit = function(text)
            return ScannerNav.applySearch(text)
        end,
    })
end
