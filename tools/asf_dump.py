"""Dump ASF object hierarchy for diff. Quick & dirty — just object GUIDs and sizes."""
import struct, sys, uuid

ASF_GUIDS = {
    "75B22630-668E-11CF-A6D9-00AA0062CE6C": "Header_Object",
    "75B22636-668E-11CF-A6D9-00AA0062CE6C": "Data_Object",
    "33000890-E5B1-11CF-89F4-00A0C90349CB": "Simple_Index_Object",
    "D6E229D3-35DA-11D1-9034-00A0C90349BE": "Index_Object",
    "FEB103F8-12AD-4C64-840F-2A1D2F7AD48C": "Media_Object_Index_Object",
    "8CABDCA1-A947-11CF-8EE4-00C00C205365": "File_Properties",
    "B7DC0791-A9B7-11CF-8EE6-00C00C205365": "Stream_Properties",
    "5FBF03B5-A92E-11CF-8EE3-00C00C205365": "Header_Extension",
    "86D15240-311D-11D0-A3A4-00A0C90348F6": "Codec_List",
    "1EFB1A30-0B62-11D0-A39B-00A0C90348F6": "Script_Command",
    "F487CD01-A951-11CF-8EE6-00C00C205365": "Marker",
    "D6E229DC-35DA-11D1-9034-00A0C90349BE": "Bitrate_Mutual_Exclusion",
    "75B22635-668E-11CF-A6D9-00AA0062CE6C": "Error_Correction",
    "75B22633-668E-11CF-A6D9-00AA0062CE6C": "Content_Description",
    "D2D0A440-E307-11D2-97F0-00A0C95EA850": "Extended_Content_Description",
    "2211B3FA-BD23-11D2-B4B7-00A0C955FC6E": "Content_Branding",
    "7BF875CE-468D-11D1-8D82-006097C9A2B2": "Stream_Bitrate_Properties",
    "2211B3FB-BD23-11D2-B4B7-00A0C955FC6E": "Content_Encryption",
    "298AE614-2622-4C17-B935-DAE07EE9289C": "Extended_Content_Encryption",
    "2211B3FC-BD23-11D2-B4B7-00A0C955FC6E": "Digital_Signature",
    "1806D474-CADF-4509-A4BA-9AABCB96AAE8": "Padding",
    "14E6A5CB-C672-4332-8399-A96952065B5A": "Extended_Stream_Properties",
    "A08649CF-4775-4670-8A16-6E35357566CD": "Advanced_Mutual_Exclusion",
    "D1465A40-5A79-4338-B71B-E36B8FD6C249": "Group_Mutual_Exclusion",
    "D4FED15B-88D3-454F-81F0-ED5C45999E24": "Stream_Prioritization",
    "A69609E6-517B-11D2-B6AF-00C04FD908E9": "Bandwidth_Sharing",
    "7C4346A9-EFE0-4BFC-B229-393EDE415C85": "Language_List",
    "C5F8CBEA-5BAF-4877-8467-AA8C44FA4CCA": "Metadata",
    "44231C94-9498-49D1-A141-1D134E457054": "Metadata_Library",
    "D6E229DF-35DA-11D1-9034-00A0C90349BE": "Index_Parameters",
    "6B203BAD-3F11-48E4-ACA8-D7613DE2CFA7": "Media_Object_Index_Parameters",
    "F8699E40-5B4D-11CF-A8FD-00805F5C442B": "Audio_Media",
    "BC19EFC0-5B4D-11CF-A8FD-00805F5C442B": "Video_Media",
    "59DACFC0-59E6-11D0-A3AC-00A0C90348F6": "Command_Media",
    "B61BE100-5B4E-11CF-A8FD-00805F5C442B": "JFIF_Media",
    "35907DE0-E415-11CF-A917-00805F5C442B": "Degradable_JPEG_Media",
    "91BD222C-F21C-497A-8B6D-5AA86BFC0185": "File_Transfer_Media",
    "3AFB65E2-47EF-40F2-AC2C-70A90D71D343": "Binary_Media",
    "20FB5700-5B55-11CF-A8FD-00805F5C442B": "No_Error_Correction",
    "BFC3CD50-618F-11CF-8BB2-00AA00B4E220": "Audio_Spread",
    "ABD3D211-A9BA-11CF-8EE6-00C00C205365": "Reserved_1",
}

def guid_str(b):
    g = uuid.UUID(bytes_le=b)
    return str(g).upper()

def dump(data, depth=0, end=None):
    if end is None: end = len(data)
    o = 0
    while o + 24 <= end:
        guid = data[o:o+16]
        size = struct.unpack_from("<Q", data, o+16)[0]
        if size < 24 or o + size > end: break
        gs = guid_str(guid)
        name = ASF_GUIDS.get(gs, f"UNKNOWN({gs})")
        print(f"{'  '*depth}{name}: size={size}")
        if name == "Header_Object":
            count = struct.unpack_from("<I", data, o+24)[0]
            print(f"{'  '*depth}  (sub-objects: {count})")
            dump(data[o+30:o+size], depth+1)
        elif name == "Header_Extension":
            ext_size = struct.unpack_from("<I", data, o+24+18)[0]
            if ext_size > 0:
                print(f"{'  '*depth}  (extension data {ext_size} bytes)")
                dump(data[o+24+22:o+24+22+ext_size], depth+1)
        o += size

with open(sys.argv[1], "rb") as f:
    data = f.read()
dump(data)
