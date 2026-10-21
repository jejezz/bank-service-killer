#ifndef RUNNER_WINDOW_PLACEMENT_H_
#define RUNNER_WINDOW_PLACEMENT_H_

#include <windows.h>

// Remembers the window rectangle in physical (virtual-screen) pixels so the
// window comes back on the same monitor in multi-display setups. Working in
// physical pixels avoids the per-monitor DPI scaling that makes logical
// coordinates inconsistent across monitors.

namespace window_placement {

constexpr wchar_t kKey[] = L"Software\\BankServiceKiller";
constexpr wchar_t kValue[] = L"WindowRect";
constexpr LONG kMinSize = 400;

inline void Save(HWND hwnd) {
  if (!hwnd || ::IsIconic(hwnd) || ::IsZoomed(hwnd)) return;
  RECT rc;
  if (!::GetWindowRect(hwnd, &rc)) return;
  HKEY key;
  if (::RegCreateKeyExW(HKEY_CURRENT_USER, kKey, 0, nullptr, 0, KEY_SET_VALUE,
                        nullptr, &key, nullptr) != ERROR_SUCCESS) {
    return;
  }
  ::RegSetValueExW(key, kValue, 0, REG_BINARY,
                   reinterpret_cast<const BYTE*>(&rc), sizeof(rc));
  ::RegCloseKey(key);
}

// Places |hwnd| at the saved rectangle if it still touches a connected
// monitor; otherwise centers it on the primary monitor's work area.
inline void Restore(HWND hwnd) {
  RECT rc;
  DWORD size = sizeof(rc);
  bool saved = ::RegGetValueW(HKEY_CURRENT_USER, kKey, kValue, RRF_RT_REG_BINARY,
                              nullptr, &rc, &size) == ERROR_SUCCESS &&
               size == sizeof(rc) && rc.right - rc.left >= kMinSize &&
               rc.bottom - rc.top >= kMinSize &&
               ::MonitorFromRect(&rc, MONITOR_DEFAULTTONULL) != nullptr;
  if (saved) {
    ::SetWindowPos(hwnd, nullptr, rc.left, rc.top, rc.right - rc.left,
                   rc.bottom - rc.top, SWP_NOZORDER | SWP_NOACTIVATE);
    return;
  }
  RECT cur, work;
  if (!::GetWindowRect(hwnd, &cur) ||
      !::SystemParametersInfoW(SPI_GETWORKAREA, 0, &work, 0)) {
    return;
  }
  LONG w = cur.right - cur.left, h = cur.bottom - cur.top;
  LONG x = work.left + ((work.right - work.left) - w) / 2;
  LONG y = work.top + ((work.bottom - work.top) - h) / 2;
  ::SetWindowPos(hwnd, nullptr, x, y, w, h, SWP_NOZORDER | SWP_NOACTIVATE);
}

}  // namespace window_placement

#endif  // RUNNER_WINDOW_PLACEMENT_H_
