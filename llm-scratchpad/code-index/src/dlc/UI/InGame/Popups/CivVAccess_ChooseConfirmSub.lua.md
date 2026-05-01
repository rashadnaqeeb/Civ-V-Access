# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseConfirmSub.lua`

79 lines · Shared Yes/No confirmation sub-handler pushed onto the HandlerStack by any Choose* popup that shows a ChooseConfirm overlay.

## Header comment

```
-- Shared Yes/No confirm-overlay sub-handler for the Choose* popups
-- (Pantheon, Ideology, Archaeology, AdmiralNewPort, TradeUnitNewHome). Each
-- of those screens wraps any pick in a "Controls.ChooseConfirm" overlay
-- with a prompt (Controls.ConfirmText) and two buttons. The button control
-- names differ per screen (Pantheon uses Yes/No, the others use
-- ConfirmYes/ConfirmNo) but the container is always Controls.ChooseConfirm.
--
-- Caller pushes this sub after the base's Select* function has shown the
-- overlay. Enter on Yes removes the sub (reactivate=false, because Yes
-- closes the whole popup anyway) and invokes opts.onYes; Enter on No
-- removes the sub (reactivate=true, so the underlying picker re-announces);
-- Esc pops via escapePops. onDeactivate hides the overlay on every exit
-- path so No / Esc / Yes all leave a clean state.
```

## Outline

- L15: `ChooseConfirmSub = {}`
- L17: `function ChooseConfirmSub.push(opts)`
- L79: `return ChooseConfirmSub`

## Notes

- L17 `ChooseConfirmSub.push`: not a constructor -- it immediately creates and pushes a new sub-handler onto the stack each time it is called; callers pass `yesControl`/`noControl` overrides when the overlay uses non-default button names.
