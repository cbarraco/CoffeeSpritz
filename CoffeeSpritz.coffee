class @Spritz
  getSelectedText: () ->
    text = ""
    if window.getSelection
      selection = window.getSelection()
      if selection.rangeCount
        container = document.createElement("div")
        for i in [0..selection.rangeCount - 1]
          container.appendChild(selection.getRangeAt(i).cloneContents())
        text = container.innerText or container.textContent
    else if document.selection
      if document.selection.type is "Text"
        text = document.selection.createRange().text
    if text is ""
      return false
    else
      return text
  constructor: () ->
    @rootDiv = document.createElement("div")
    @rootDiv.id = "spritz_root"
    @rootDiv.align = "center"
    @rootDiv.style.position = "fixed"
    @rootDiv.style.zIndex = "9999"
    @rootDiv.style.width = "400px"
    @rootDiv.style.left = "50%"
    @rootDiv.style.margin = "0px"
    @rootDiv.style.marginLeft = "-200px"
    @rootDiv.style.padding = "10px"
    @rootDiv.style.backgroundColor = "white"
    @rootDiv.style.borderColor = "black"
    @rootDiv.style.borderStyle = "solid"
    @rootDiv.style.borderWidth = "3px"
    @rootDiv.style.cursor = "move"
    @mouseDown = false
    @rootDiv.addEventListener "mousedown", () =>
      @mouseDown = true
    @rootDiv.addEventListener "mouseup", () =>
      @mouseDown = false
    @rootDiv.addEventListener "mousemove", (mouseEvent) =>
      if @mouseDown
        @rootDiv.style.left = mouseEvent.clientX + "px"
        @rootDiv.style.top = mouseEvent.clientY - 40 + "px"
      mouseEvent.preventDefault()
    @rootDiv.addEventListener "mouseleave", () =>
      @mouseDown = false
    font = "bold 32px Courier"
    @wordDiv = @addUiElement("div", "spritz_word", @rootDiv)
    @formerSpan = @addUiElement("span", "spritz_former", @wordDiv)
    @formerSpan.style.font = font
    @pivotSpan = @addUiElement("span", "spritz_pivot", @wordDiv)
    @pivotSpan.style.font = font
    @pivotSpan.style.color = "red"
    @latterSpan = @addUiElement("span", "spritz_latter", @wordDiv)
    @latterSpan.style.font = font
    @controlsDiv = @addUiElement("div", "spritz_controls", @rootDiv)
    @wpmSelectLabel = @addUiElement("label", "spritz_wpmlabel", @controlsDiv)
    @wpmSelectLabel.innerHTML = "WPM:"
    @wpmSelect = @addUiElement("select", "spritz_wpm", @controlsDiv)
    for wpm in [200..1000] by 50
      wpmOption = document.createElement("option")
      wpmOption.text = wpm
      @wpmSelect.add(wpmOption)
    @wpmSelect.removeAttribute("style")
    @startButton = @addUiElement("button", "spritz_start", @controlsDiv)
    @startButton.onclick = () ->
      spritz.start()
    @startButton.innerHTML = "Start"
    @startButton.removeAttribute("style")
    @closeButton = @addUiElement("button", "spritz_close", @controlsDiv)
    @closeButton.onclick = () ->
      spritz.remove()
    @closeButton.innerHTML = "Close"
    @closeButton.removeAttribute("style")
    if document.body.firstChild
      document.body.insertBefore(@rootDiv, document.body.firstChild)
    else
      document.body.appendChild(@rootDiv)
  addUiElement: (type, id, parent) ->
    element = document.createElement(type)
    element.id = id
    parent.appendChild(element)
    return element
  remove: () ->
    document.body.removeChild(@rootDiv)
  getWPM: () ->
    selectedIndex = @wpmSelect.selectedIndex
    wpm = @wpmSelect.options[selectedIndex].text
    return parseInt(wpm)
  setWord: (word) ->
    pivotIndex = 0
    if word.length > 1
      pivotIndex = word.length / 2 - 1 # Take the floor to make an odd length word more right heavy
    pivot = word.charAt(pivotIndex)
    @pivotSpan.innerHTML = pivot
    latter = ""
    if word.length > 1
      latter = word.slice(pivotIndex + 1, word.length)
    former = ""
    if word.length > 2
      former = word.slice(0, pivotIndex)
    while former.length > latter.length
      latter += "\u00A0"
    while latter.length > former.length
      former = "\u00A0" + former
    @formerSpan.innerHTML = former
    @latterSpan.innerHTML = latter
  start: () ->
    selection = @getSelectedText()
    if not selection or selection.length is 0
      alert("Please select text to Spritz")
      return
    selection.replace(/\./, ".\u00A0") # If paragraph ends in a period it joins with the first word of the next paragraph
    words = selection.split(/\s+/)
    currentWordIndex = 0
    callback = () =>
      if currentWordIndex < words.length
        @setWord(words[currentWordIndex++])
      else
        clearInterval(intervalId)
    wpm = @getWPM()
    intervalId = setInterval(callback, 60000 / wpm)
spritz = new Spritz()
spritz.setWord("CoffeeSpritz")
