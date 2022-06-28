import x11/[xlib, x, xft]
import std/options

type
  Layout* = enum
    lyFloating, lyTiling
  FramePart* = enum
    fpTitle, fpClose, fpMaximize, fpMinimize
  ButtonState* = enum
    bsActive, bsInactive, bsActiveHover, bsInactiveHover
  Geometry* = object
    x*, y*: int
    width*, height*: uint
  MotionInfo* = object
    start*: XButtonEvent
    attr*: XWindowAttributes
  Frame* = object
    window*, top*, title*: Window
    close*, maximize*, minimize*: Window # button parts
    closeHovered*, maximizeHovered*, minimizeHovered*: bool # is the button being hovered over? for reading by renderTop, and set by Enter / Leave Notify events.
  Client* = object
    window*: Window
    frame*: Frame
    draw*: ptr XftDraw
    color*: XftColor
    title*: string
    beforeGeom*: Option[Geometry] # Previous geometry *of the frame* pre-fullscreen.
    fullscreen*: bool # Whether this client is currently fullscreened or not (EWMH, or otherwise ig)
    floating*: bool # If tiling is on, whether this window is currently floating or not. If it's floating it won't be included in the tiling.
    tags*: TagSet
    frameHeight*: uint
    csd*: bool
    class*: string
    beforeGeomMax*: Option[Geometry]
    maximized*: bool
    minimized*: bool
  ButtonPaths = array[ButtonState, string]
  Config* = object
    borderActivePixel*, borderInactivePixel*, borderWidth*: uint
    frameActivePixel*, frameInactivePixel*, frameHeight*: uint
    textActivePixel*: uint
    textInactivePixel*: uint
    textOffset*, buttonOffset*: tuple[x, y: uint]
    gaps*: int # TODO: fix the type errors and change this to unsigned integers.
    struts*: tuple[top, bottom, left, right: uint]
    frameParts*: tuple[left, center, right: seq[FramePart]]
    buttonSize*: uint # always square FOR NOW
    rootMenu*: string
    closePaths*, minimizePaths*, maximizePaths*: ButtonPaths
    modifier*: uint32
  TagSet* = array[9, bool] # distinct

proc defaultTagSet*: TagSet = [true, false, false, false, false, false, false,
    false, false] # put the user on tag 1 when the wm starts.

proc switchTag*(self: var TagSet; tag: uint8): void =
  for i, _ in self: self[i] = false
  self[tag] = true

