Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'---------------------------------------------------------------------------------------
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : This class extends the IDbComponent class to perform the specific
'           : operations required by this particular object type.
'           : (I.e. The specific way you export or import this component.)
'---------------------------------------------------------------------------------------
Option Compare Database
Option Explicit

Private m_Table As AccessObject
Private m_Options As clsOptions
'Private m_Count As Long (uncomment if needed)

' This requires us to use all the public methods and properties of the implemented class
' which keeps all the component classes consistent in how they are used in the export
' and import process. The implemented functions should be kept private as they are called
' from the implementing class, not this class.
Implements IDbComponent


'---------------------------------------------------------------------------------------
' Procedure : Export
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : Export the individual database component (table, form, query, etc...)
'---------------------------------------------------------------------------------------
'
Private Sub IDbComponent_Export()

    Dim strSQL As String
    Dim rst As ADODB.Recordset
    Dim intRst As Integer
    Dim fld As ADODB.Field
    Dim colText As New clsConcat
    
    ' Initialize counter
    intRst = 2
    
    ' Get initial table information
    strSQL = "exec sp_help N'" & m_Table.Name & "'"
    Set rst = CurrentProject.Connection.Execute(strSQL)
    colText.Add "-- sp_help Recordset 1" & vbCrLf & vbCrLf
    For Each fld In rst.Fields
        colText.Add fld.Name
        colText.Add vbTab
    Next fld
    colText.Add vbCrLf
    colText.Add rst.GetString(, , vbTab, vbCrLf)
    
    ' Loop through additional recordsets for columns, keys and other data
    Do
        Set rst = rst.NextRecordset
        If rst Is Nothing Then Exit Do
        If rst.State = adStateClosed Then Exit Do
        
        colText.Add vbCrLf & vbCrLf & "-- sp_help Recordset " & intRst & vbCrLf & vbCrLf
        For Each fld In rst.Fields
            colText.Add fld.Name
            colText.Add vbTab
        Next fld
        If Not rst.EOF Then
            colText.Add vbCrLf
            colText.Add rst.GetString(, , vbTab, vbCrLf)
        End If
        
        intRst = intRst + 1
    Loop
    
    ' Clear references
    Set fld = Nothing
    Set rst = Nothing
    
    ' Write SQL text to file
    WriteFile colText.GetStr, IDbComponent_SourceFile
    
End Sub


'---------------------------------------------------------------------------------------
' Procedure : Import
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : Import the individual database component from a file.
'---------------------------------------------------------------------------------------
'
Private Sub IDbComponent_Import(strFile As String)

End Sub


'---------------------------------------------------------------------------------------
' Procedure : GetAllFromDB
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : Return a collection of class objects represented by this component type.
'---------------------------------------------------------------------------------------
'
Private Function IDbComponent_GetAllFromDB(Optional cOptions As clsOptions) As Collection
    
    Dim tbl As AccessObject
    Dim cTable As IDbComponent

    ' Use parameter options if provided.
    If Not cOptions Is Nothing Then Set IDbComponent_Options = cOptions

    Set IDbComponent_GetAllFromDB = New Collection
    For Each tbl In CurrentData.AllTables
        Set cTable = New clsAdpTable
        Set cTable.DbObject = tbl
        Set cTable.Options = IDbComponent_Options
        IDbComponent_GetAllFromDB.Add cTable, tbl.Name
    Next tbl

End Function


'---------------------------------------------------------------------------------------
' Procedure : GetFileList
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : Return a list of file names to import for this component type.
'---------------------------------------------------------------------------------------
'
Private Function IDbComponent_GetFileList() As Collection
    Set IDbComponent_GetFileList = GetFilePathsInFolder(IDbComponent_BaseFolder & "*.txt")
End Function


'---------------------------------------------------------------------------------------
' Procedure : ClearOrphanedSourceFiles
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : Remove any source files for objects not in the current database.
'---------------------------------------------------------------------------------------
'
Private Function IDbComponent_ClearOrphanedSourceFiles() As Variant
    ClearFilesByExtension IDbComponent_BaseFolder, "tdf"    ' Legacy extension
    ClearOrphanedSourceFiles Me, "txt"
End Function


'---------------------------------------------------------------------------------------
' Procedure : DateModified
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : The date/time the object was modified. (If possible to retrieve)
'           : If the modified date cannot be determined (such as application
'           : properties) then this function will return 0.
'---------------------------------------------------------------------------------------
'
Private Function IDbComponent_DateModified() As Date
    IDbComponent_DateModified = GetSQLObjectModifiedDate(m_Table.Name, estTable)
End Function


'---------------------------------------------------------------------------------------
' Procedure : SourceModified
' Author    : Adam Waller
' Date      : 4/27/2020
' Purpose   : The date/time the source object was modified. In most cases, this would
'           : be the date/time of the source file, but it some cases like SQL objects
'           : the date can be determined through other means, so this function
'           : allows either approach to be taken.
'---------------------------------------------------------------------------------------
'
Public Function IDbComponent_SourceModified() As Date
    If FSO.FileExists(IDbComponent_SourceFile) Then IDbComponent_SourceModified = FileDateTime(IDbComponent_SourceFile)
End Function


'---------------------------------------------------------------------------------------
' Procedure : Category
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : Return a category name for this type. (I.e. forms, queries, macros)
'---------------------------------------------------------------------------------------
'
Private Property Get IDbComponent_Category() As String
    IDbComponent_Category = "tables"
End Property


'---------------------------------------------------------------------------------------
' Procedure : BaseFolder
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : Return the base folder for import/export of this component.
'---------------------------------------------------------------------------------------
Private Property Get IDbComponent_BaseFolder() As String
    IDbComponent_BaseFolder = IDbComponent_Options.GetExportFolder & "tables\"
End Property


'---------------------------------------------------------------------------------------
' Procedure : Name
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : Return a name to reference the object for use in logs and screen output.
'---------------------------------------------------------------------------------------
'
Private Property Get IDbComponent_Name() As String
    IDbComponent_Name = m_Table.Name
End Property


'---------------------------------------------------------------------------------------
' Procedure : SourceFile
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : Return the full path of the source file for the current object.
'---------------------------------------------------------------------------------------
'
Private Property Get IDbComponent_SourceFile() As String
    IDbComponent_SourceFile = IDbComponent_BaseFolder & GetSafeFileName(StripDboPrefix(m_Table.Name)) & ".txt"
End Property


'---------------------------------------------------------------------------------------
' Procedure : Count
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : Return a count of how many items are in this category.
'---------------------------------------------------------------------------------------
'
Private Property Get IDbComponent_Count() As Long
    IDbComponent_Count = CurrentData.AllTables.Count
End Property


'---------------------------------------------------------------------------------------
' Procedure : ComponentType
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : The type of component represented by this class.
'---------------------------------------------------------------------------------------
'
Private Property Get IDbComponent_ComponentType() As eDatabaseComponentType
    IDbComponent_ComponentType = edbAdpTable
End Property


'---------------------------------------------------------------------------------------
' Procedure : Upgrade
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : Run any version specific upgrade processes before importing.
'---------------------------------------------------------------------------------------
'
Private Sub IDbComponent_Upgrade()
    ' No upgrade needed.
End Sub


'---------------------------------------------------------------------------------------
' Procedure : Options
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : Return or set the options being used in this context.
'---------------------------------------------------------------------------------------
'
Private Property Get IDbComponent_Options() As clsOptions
    If m_Options Is Nothing Then Set m_Options = LoadOptions
    Set IDbComponent_Options = m_Options
End Property
Private Property Set IDbComponent_Options(ByVal RHS As clsOptions)
    Set m_Options = RHS
End Property


'---------------------------------------------------------------------------------------
' Procedure : DbObject
' Author    : Adam Waller
' Date      : 4/23/2020
' Purpose   : This represents the database object we are dealing with.
'---------------------------------------------------------------------------------------
'
Private Property Get IDbComponent_DbObject() As Object
    Set IDbComponent_DbObject = m_Table
End Property
Private Property Set IDbComponent_DbObject(ByVal RHS As Object)
    Set m_Table = RHS
End Property


'---------------------------------------------------------------------------------------
' Procedure : SingleFile
' Author    : Adam Waller
' Date      : 4/24/2020
' Purpose   : Returns true if the export of all items is done as a single file instead
'           : of individual files for each component. (I.e. properties, references)
'---------------------------------------------------------------------------------------
'
Public Property Get IDbComponent_SingleFile() As Boolean
End Property


'---------------------------------------------------------------------------------------
' Procedure : Class_Initialize
' Author    : Adam Waller
' Date      : 4/24/2020
' Purpose   : Helps us know whether we have already counted the objects.
'---------------------------------------------------------------------------------------
'
Private Sub Class_Initialize()
    'm_Count = -1
End Sub


'---------------------------------------------------------------------------------------
' Procedure : Parent
' Author    : Adam Waller
' Date      : 4/24/2020
' Purpose   : Return a reference to this class as an IDbComponent. This allows you
'           : to reference the public methods of the parent class without needing
'           : to create a new class object.
'---------------------------------------------------------------------------------------
'
Public Property Get Parent() As IDbComponent
    Set Parent = Me
End Property